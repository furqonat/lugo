import { otpGenerator, sendSms } from '@lugo/common'
import { FirebaseService } from '@lugo/firebase'
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
export class DriverService {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly firebase: FirebaseService
  ) {}

  async getDriver(driverId: string, select?: Prisma.driverSelect) {
    try {
      const driver = await this.prismaService.driver.findUnique({
        where: {
          id: driverId,
        },
        select: select ? select : { id: true },
      })
      return driver
    } catch (e) {
      throw new NotFoundException({ message: 'Driver not found', error: e })
    }
  }

  async applyDriver(
    driverId: string,
    options: {
      details: Prisma.driver_detailsCreateInput
      referal: string
      name: string
      phone: string
    }
  ) {
    const { details, referal, name, phone } = options
    try {
      const ref = await this.prismaService.referal.findUnique({
        where: {
          ref: referal,
        },
      })
      const alreadyApply = await this.prismaService.driver_details.findUnique({
        where: {
          driver_id: driverId,
        },
      })
      if (alreadyApply) {
        throw new BadRequestException({ message: 'already apply for driver' })
      }
      const createDetail = await this.prismaService.driver.update({
        where: {
          id: driverId,
        },
        data: {
          name: name,
          phone: phone,
          driver_details: {
            create: details,
          },
          referal: {
            connect: {
              id: ref.id,
            },
          },
        },
        include: {
          driver_details: true,
        },
      })
      await this.firebase.firestore.collection('drivers').doc(driverId).create({
        id: driverId,
        isOnline: createDetail.is_online,
        address: createDetail.driver_details.address,
        latitude: createDetail.driver_details.current_lat,
        longitude: createDetail.driver_details.current_lng,
        name: createDetail.name,
        type: createDetail.driver_details.driver_type,
      })
      return {
        message: 'OK',
        res: createDetail.driver_details.id,
      }
    } catch (e) {
      throw new BadRequestException({
        message: 'Unexpected error',
        error: e,
      })
    }
  }

  async updateDriverDetail(driverId: string, options: unknown) {
    console.log(JSON.stringify(options, undefined, 2))
    try {
      const driver = await this.prismaService.driver_details.update({
        where: {
          driver_id: driverId,
        },
        data: options,
      })
      return {
        message: 'OK',
        res: driver.id,
      }
    } catch (e) {
      throw new InternalServerErrorException(e)
    }
  }

  async updateDriverSettings(
    driverId: string,
    autoBid?: boolean,
    isOnline?: boolean
  ) {
    try {
      const driver = await this.prismaService.driver.update({
        where: {
          id: driverId,
        },
        data: {
          is_online: isOnline ?? undefined,
          driver_settings: {
            update: {
              where: {
                driver_id: driverId,
              },
              data: {
                auto_bid: autoBid ?? undefined,
              },
            },
          },
        },
      })
      const frs = await this.firebase.firestore
        .collection('drivers')
        .doc(driver.id)
        .update({
          isOnline: isOnline ?? undefined,
        })
      return {
        message: 'OK',
        res: driver.id + frs.writeTime,
      }
    } catch (e) {
      throw new InternalServerErrorException(e)
    }
  }

  async updateOrderSetting(
    driverId: string,
    data: Prisma.driver_settingsUpdateInput
  ) {
    try {
      const driver = await this.prismaService.driver_settings.update({
        where: {
          driver_id: driverId,
        },
        data: data,
      })
      return {
        message: 'OK',
        res: driver.id,
      }
    } catch (e) {
      throw new BadRequestException({ message: 'Bad Request' })
    }
  }

  async saveDeviceToken(driverId: string, token: string) {
    const deviceTokenExist =
      await this.prismaService.driver_device_token.findUnique({
        where: {
          driver_id: driverId,
        },
      })
    if (deviceTokenExist) {
      const deviceToken = await this.prismaService.driver_device_token.update({
        where: {
          driver_id: driverId,
        },
        data: {
          token: token,
        },
      })
      return {
        message: 'OK',
        res: deviceToken.id,
      }
    }
    const deviceToken = await this.prismaService.driver_device_token.create({
      data: {
        token: token,
        driver_id: driverId,
      },
    })
    return {
      message: 'OK',
      res: deviceToken.id,
    }
  }

  async updateCurrentLatLon(
    driverId: string,
    latitude: number,
    longitude: number
  ) {
    try {
      const driver = await this.prismaService.driver.update({
        where: {
          id: driverId,
        },
        data: {
          driver_details: {
            update: {
              where: {
                driver_id: driverId,
              },
              data: {
                current_lat: latitude,
                current_lng: longitude,
              },
            },
          },
        },
      })
      const frs = await this.firebase.firestore
        .collection('drivers')
        .doc(driver.id)
        .update({
          latitude: latitude,
          longitude: longitude,
        })
      return {
        message: 'OK',
        res: driver.id + frs.writeTime,
      }
    } catch (e) {
      throw new InternalServerErrorException(e)
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

    const data = await this.prismaService.driver.findFirst({
      where: {
        id: uid,
      },
    })

    if (data) {
      let htmlstream = await readFileSync(
        './libs/common/src/html/otp_verification.html'
      )
      let html: any = htmlstream.toString()
      html = html
        .replaceAll('{{ otp }}', code)
        .replaceAll('{{ username }}', data.name)
        .replaceAll('{{ date }}', new Date().toLocaleDateString('id-ID'))

      const response = await sendEmail(
        data.email,
        'Email One Time Password',
        'Email One Time Password for ' + data.name,
        html
      )

      return {
        message: 'OK',
        res: {
          data: data,
          verifcationId: verifcationId.id,
        },
      }
    }

    await this.prismaService.verification.delete({
      where: {
        id: verifcationId.id,
      },
    })
    return {
      message: 'Data tidak ditemukan',
      res: data,
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
    driverId: string,
    verifcationId: string,
    smsCode: number
  ) {
    const verification = await this.prismaService.verification.findUnique({
      where: {
        id: verifcationId,
      },
    })
    if (verification.code == smsCode) {
      await this.prismaService.driver.update({
        where: {
          id: driverId,
        },
        data: {
          phone_verified: true,
          phone: verification.phone,
        },
      })
      return {
        message: 'OK',
        res: driverId,
      }
    }
    throw new UnauthorizedException({
      message: 'Invalid verification code',
    })
  }
}
