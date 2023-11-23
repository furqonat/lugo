import { FirebaseService } from '@lugo/firebase'
import { Prisma, UsersPrismaService } from '@lugo/users'
import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common'

@Injectable()
export class DriverService {
  constructor(
    private readonly prismaService: UsersPrismaService,
    private readonly firebase: FirebaseService,
  ) {}

  async getDriver(token: string, select?: Prisma.driverSelect) {
    try {
      const decodeToken = await this.firebase.auth.verifyIdToken(token)
      const driver = await this.prismaService.driver.findUnique({
        where: {
          id: decodeToken.uid,
        },
        select: select ? select : { id: true },
      })
      return driver
    } catch (e) {
      throw new NotFoundException({ message: 'Driver not found', error: e })
    }
  }

  async applyDriver(
    token: string,
    options: {
      details: Prisma.driver_detailsCreateInput
    },
  ) {
    const { details } = options
    try {
      const decodeToken = await this.firebase.auth.verifyIdToken(token)
      const alreadyApply = await this.prismaService.driver_details.findUnique({
        where: {
          driver_id: decodeToken.uid,
        },
      })
      if (alreadyApply) {
        throw new BadRequestException({ message: 'allready apply for driver' })
      }
      const createDetail = await this.prismaService.driver.update({
        where: {
          id: decodeToken.id,
        },
        data: {
          driver_details: {
            create: details,
          },
        },
        include: {
          driver_details: true,
        },
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
}