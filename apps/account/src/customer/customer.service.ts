import {
  HttpStatus,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common'
import { Prisma, PrismaService } from '@lugo/prisma'
import { FirebaseService } from '@lugo/firebase'
import { CustomerBasicUpdate } from '../dto/customer.dto'
import { otpGenerator } from '@lugo/common'
import { readFileSync } from 'fs'
import { sendEmail } from 'libs/common/src/lib/custom'

@Injectable()
export class CustomerService {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly firebase: FirebaseService,
  ) {}

  async getCustomer(customerId: string, select?: Prisma.customerSelect) {
    try {
      const customer = await this.prismaService.customer.findUnique({
        where: {
          id: customerId,
        },
        select: select ? select : { id: true },
      })
      return customer
    } catch (e) {
      throw new NotFoundException({ message: 'User not found', error: e })
    }
  }

  async basicUpdate(customerId: string, data: CustomerBasicUpdate) {
    try {
      const customer = await this.getCustomer(customerId, {
        id: true,
        name: true,
        avatar: true,
        email: true,
        phone: true,
      })
      await this.prismaService.customer.update({
        where: {
          id: customerId,
        },
        data: {
          name: data.name ?? customer.name,
          avatar: data.avatar ?? customer.avatar,
          email: data.email ?? customer.email,
          phone: data.phoneNumber ?? customer.phone,
        },
      })
      await this.firebase.auth.updateUser(customerId, {
        displayName: data?.name ?? customer.name,
        photoURL: data?.avatar ?? customer.avatar,
        phoneNumber: data?.phoneNumber ?? customer.phone,
        email: data?.email ?? customer.email,
      })
      return {
        message: 'OK',
        res: customerId,
      }
    } catch (e) {
      throw new InternalServerErrorException({
        message: `Internal Server Error ${e?.toString()}`,
      })
    }
  }

  async saveDeviceToken(customerId: string, token: string) {
    const deviceTokenExist =
      await this.prismaService.customer_device_token.findUnique({
        where: {
          customer_id: customerId,
        },
      })
    if (deviceTokenExist) {
      const deviceToken = await this.prismaService.customer_device_token.update(
        {
          where: {
            customer_id: customerId,
          },
          data: {
            token: token,
          },
        },
      )
      return {
        message: 'OK',
        res: deviceToken.id,
      }
    }
    const deviceToken = await this.prismaService.customer_device_token.create({
      data: {
        token: token,
        customer_id: customerId,
      },
    })
    return {
      message: 'OK',
      res: deviceToken.id,
    }
  }

  async obtainVerificationCode(phone: string, uid: string) {
    const code = otpGenerator()
    const verifcationId = await this.prismaService.verification.create({
      data: {
        phone: phone,
        code: code,
      },
    })
    const data = await this.prismaService.customer.findFirst({
      where: {
        id: uid
      }
    })

    if(data){
      let htmlstream = await readFileSync("./libs/common/src/html/otp_verification.html");
      let html :any = htmlstream.toString();
      html = html.replaceAll("{{ otp }}", code)
            .replaceAll("{{ username }}", data.name)
            .replaceAll("{{ date }}", new Date().toLocaleDateString("id-ID"))

      const response = await sendEmail(data.email,
        "Email One Time Password",
        "Email One Time Password for " + data.name,
        html
      );

      return {
        message: 'OK',
        res: verifcationId.id,
      }
    }
    return {
      message: "Data tidak ditemukan",
      res: data
    }
    // const resp = await sendSms(phone, `${code}`)
    // if (resp == HttpStatus.CREATED) {
    //   return {
    //     message: 'OK',
    //     res: verifcationId.id,
    //   }
    // } else {
    //   await this.prismaService.verification.delete({
    //     where: {
    //       id: verifcationId.id,
    //     },
    //   })
    //   throw new InternalServerErrorException({
    //     message: 'Internal Server Error',
    //     error: resp,
    //   })
    // }
  }

  async phoneVerification(
    customerId: string,
    verifcationId: string,
    smsCode: number,
  ) {
    const verification = await this.prismaService.verification.findUnique({
      where: {
        id: verifcationId,
      },
    })
    if (verification.code == smsCode) {
      await this.prismaService.customer.update({
        where: {
          id: customerId,
        },
        data: {
          phone_verified: true,
          phone: verification.phone,
        },
      })
      return {
        message: 'OK',
        res: customerId,
      }
    }
    throw new UnauthorizedException({
      message: 'Invalid verification code',
    })
  }
}
