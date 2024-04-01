import {
  Body,
  Controller,
  Get,
  Post,
  Put,
  Query,
  Request,
  UseGuards,
  Param,
  UnauthorizedException,
} from '@nestjs/common'
import { Prisma } from '@prisma/client/users'
import { str2obj } from '@lugo/common'
import { MerchantService } from './merchant.service'
import { Role, Roles, RolesGuard } from '@lugo/guard'

@UseGuards(RolesGuard)
@Controller('merchant')
export class MerchantController {
  constructor(private readonly merchantService: MerchantService) {}

  @Roles(Role.MERCHANT)
  @Get()
  async getMerchant(
    @Request() token?: { uid?: string },
    @Query() select?: Prisma.merchantSelect,
  ) {
    return this.merchantService.getMerchant(token.uid, str2obj(select))
  }

  @Roles(Role.MERCHANT)
  @Post()
  async applyToBeMerchant(
    @Request() token?: { uid?: string },
    @Body()
    details?: Prisma.merchantUpdateInput,
  ) {
    return this.merchantService.applyMerchant(token.uid, details)
  }

  @Roles(Role.MERCHANT)
  @Post('/operation')
  async createOperationTime(
    @Request() token?: { uid?: string },
    @Body()
    data?: Prisma.merchant_operation_timeUpdateManyWithoutMerchant_detailsNestedInput,
  ) {
    return this.merchantService.createOrUpdateOperationTime(token.uid, data)
  }

  @Roles(Role.MERCHANT)
  @Post('/token')
  async addOrEditDeviceToken(
    @Body('token') token: string,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.merchantService.saveDeviceToken(req.uid, token)
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.MERCHANT)
  @Post('/phone/verification')
  async obtainVerificationCode(
    @Body('phone') phone: string,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.merchantService.obtainVerificationCode(phone, req.uid)
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.MERCHANT)
  @Post('/phone/verification/:verificationId')
  async verifyVerificationCode(
    @Param('verificationId') verificationId: string,
    @Body('code') code: number,
    @Request() req?: { uid?: string },
  ) {
    if (req?.uid) {
      return this.merchantService.phoneVerification(
        req?.uid,
        verificationId,
        code,
      )
    }
    throw new UnauthorizedException()
  }

  @Roles(Role.MERCHANT)
  @Put('/operation/:id')
  async updateOperationTime(
    @Param('id') opId: string,
    @Body() data?: Prisma.merchant_operation_timeUpdateInput,
  ) {
    return this.merchantService.updateOperationTime(opId, data)
  }

  @Roles(Role.MERCHANT)
  @Put('/:id')
  async updateMerchant(
    @Body() data: Prisma.merchantUpdateInput,
    @Request() req?: { uid?: string },
  ) {
    if (!req?.uid) {
      throw new UnauthorizedException()
    }
    return this.merchantService.updateMerchat(req.uid, data)
  }
}
