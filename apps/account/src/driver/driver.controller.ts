import { str2obj } from '@lugo/common'
import { Role, Roles, RolesGuard } from '@lugo/guard'
import {
  Body,
  Controller,
  Get,
  Post,
  Put,
  Query,
  Request,
  UnauthorizedException,
  UseGuards,
  Param,
} from '@nestjs/common'
import { Prisma } from '@prisma/client/users'
import { DriverService } from './driver.service'
import { ApplyDriver } from '../dto/driver.dto'

@UseGuards(RolesGuard)
@Controller('driver')
export class DriverController {
  constructor(private readonly driverService: DriverService) {}

  @Roles(Role.DRIVER)
  @Get()
  async getDriver(
    @Request() req?: { uid?: string },
    @Query() select?: Prisma.driverSelect,
  ) {
    return this.driverService.getDriver(req.uid, str2obj(select))
  }

  @Roles(Role.DRIVER)
  @Post()
  async applyToBeDriver(
    @Request() req?: { uid?: string },
    @Body() details?: ApplyDriver,
  ) {
    return this.driverService.applyDriver(req.uid, {
      details: details.details,
      referal: details.referal,
      name: details.name,
      phone: details.phone,
    })
  }

  @Roles(Role.DRIVER)
  @Put()
  async updateApplyDriver(
    @Request() token: { uid?: string },
    @Body() data: unknown,
  ) {
    console.log(data)
    return this.driverService.updateDriverDetail(token.uid, data)
  }

  @Roles(Role.DRIVER)
  @Post('/token')
  async addOrEditDeviceToken(
    @Body('token') token: string,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.driverService.saveDeviceToken(req.uid, token)
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.DRIVER)
  @Put('/setting')
  async updateDriverSetting(
    @Body() data: { isOnline: boolean; autoBid: boolean },
    @Request() token?: { uid?: string },
  ) {
    if (!token?.uid) {
      throw new UnauthorizedException()
    }
    return this.driverService.updateDriverSettings(
      token.uid,
      data.autoBid,
      data.isOnline,
    )
  }

  @Roles(Role.DRIVER)
  @Put('/setting/order')
  async updateOrderSetting(
    @Request() token: { uid?: string },
    @Body() data: Prisma.driver_settingsUpdateInput,
  ) {
    return this.driverService.updateOrderSetting(token.uid, data)
  }

  @Roles(Role.DRIVER)
  @Put('/setting/coordinate')
  async updateDriverCoordinate(
    @Body() data: { latitude: number; longitude: number },
    @Request() token?: { uid?: string },
  ) {
    if (!token?.uid) {
      throw new UnauthorizedException()
    }
    return this.driverService.updateCurrentLatLon(
      token.uid,
      data.latitude,
      data.longitude,
    )
  }

  @Roles(Role.DRIVER)
  @Post('/phone/verification')
  async obtainVerificationCode(
    @Body('phone') phone: string,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.driverService.obtainVerificationCode(phone, req.uid)
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.DRIVER)
  @Post('/phone/verification/:verificationId')
  async verifyVerificationCode(
    @Param('verificationId') verificationId: string,
    @Body('code') code: number,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.driverService.phoneVerification(
        req?.uid,
        verificationId,
        code,
      )
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.DRIVER, Role.USER)
  @Get('/:id')
  async getDriverById(
    @Param('id') driverId: string,
    @Query() select?: Prisma.driverSelect,
  ) {
    return this.driverService.getDriver(driverId, str2obj(select))
  }
}
