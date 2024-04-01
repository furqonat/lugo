import { otpGenerator, sendSms } from '@lugo/common'
import { Prisma, PrismaService } from '@lugo/prisma'
import {
  BadRequestException,
  HttpStatus,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common'
import { readFileSync } from 'fs'
import { sendEmail } from 'libs/common/src/lib/custom'

@Injectable()
export class MerchantService {
  constructor(private readonly prismaService: PrismaService) {}

  async getMerchant(merchantId: string, select: Prisma.merchantSelect) {
    try {
      const merchant = await this.prismaService.merchant.findUnique({
        where: {
          id: merchantId,
        },
        select: select
          ? select
          : {
              id: true,
            },
      })
      return merchant
    } catch (e) {
      throw new NotFoundException()
    }
  }

  async applyMerchant(merchantId: string, details: Prisma.merchantUpdateInput) {
    try {
      const alreadyApply = await this.prismaService.merchant_details.findUnique(
        {
          where: {
            merchant_id: merchantId,
          },
        },
      )
      if (alreadyApply) {
        throw new BadRequestException({ message: 'merchant already apply' })
      }
      const merchant = await this.prismaService.merchant.update({
        where: {
          id: merchantId,
        },
        data: details,
      })
      return {
        message: 'OK',
        res: merchant.id,
      }
    } catch (e) {
      throw new BadRequestException({
        message: `Internal Error ${e.toString()}`,
      })
    }
  }

  async createOrUpdateOperationTime(
    merchantId: string,
    data: Prisma.merchant_operation_timeUpdateManyWithoutMerchant_detailsNestedInput,
  ) {
    try {
      const merchant = await this.prismaService.merchant.findUnique({
        where: {
          id: merchantId,
        },
        select: {
          details: {
            select: {
              id: true,
            },
          },
        },
      })
      if (merchant.details.id) {
        const details = await this.prismaService.merchant_details.update({
          where: {
            id: merchant.details.id,
          },
          data: {
            operation_time: data,
          },
        })
        return {
          message: 'OK',
          res: details.id,
        }
      } else {
        throw new BadRequestException()
      }
    } catch (e) {
      throw new BadRequestException(e)
    }
  }

  async updateOperationTime(
    opId: string,
    data: Prisma.merchant_operation_timeUpdateInput,
  ) {
    const res = await this.prismaService.merchant_operation_time.update({
      where: {
        id: opId,
      },
      data: {
        day: data.day,
        open_time: data.open_time,
        close_time: data.close_time,
        status: data.status,
      },
    })
    return {
      message: 'OK',
      res: res,
    }
  }

  async saveDeviceToken(merchantId: string, token: string) {
    const deviceTokenExist =
      await this.prismaService.merchant_device_token.findUnique({
        where: {
          merchant_id: merchantId,
        },
      })
    if (deviceTokenExist) {
      const deviceToken = await this.prismaService.merchant_device_token.update(
        {
          where: {
            merchant_id: merchantId,
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
    const deviceToken = await this.prismaService.merchant_device_token.create({
      data: {
        token: token,
        merchant_id: merchantId,
      },
    })
    return {
      message: 'OK',
      res: deviceToken.id,
    }
  }

  async updateMerchat(merchantId: string, data: Prisma.merchantUpdateInput) {
    const merchant = await this.prismaService.merchant.update({
      where: {
        id: merchantId,
      },
      data: data,
    })

    return {
      message: 'OK',
      res: merchant.id,
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

    const data = await this.prismaService.merchant.findFirst({
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

    // const resp = await sendSms(phone, `{code}`)
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
    merchantId: string,
    verifcationId: string,
    smsCode: number,
  ) {
    const verification = await this.prismaService.verification.findUnique({
      where: {
        id: verifcationId,
      },
    })
    if (verification.code == smsCode) {
      await this.prismaService.merchant.update({
        where: {
          id: merchantId,
        },
        data: {
          phone_verified: true,
          phone: verification.phone,
        },
      })
      return {
        message: 'OK',
        res: merchantId,
      }
    }
    throw new UnauthorizedException({
      message: 'Invalid verification code',
    })
  }
}
