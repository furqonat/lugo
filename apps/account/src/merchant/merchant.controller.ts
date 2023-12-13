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
    @Body() details?: Prisma.merchant_detailsCreateInput,
  ) {
    return this.merchantService.applyMerchant(token.uid, details)
  }

  @Roles(Role.MERCHANT)
  @Post('/operation')
  async createOperationTime(
    @Request() token?: { uid?: string },
    @Body() data?: Prisma.merchant_operation_timeCreateInput,
  ) {
    return this.merchantService.createOperationTime(token.uid, data)
  }

  @Roles(Role.MERCHANT)
  @Put('/operation/:id')
  async updateOperationTime(
    @Param('id') opId: string,
    @Body() data?: Prisma.merchant_operation_timeUpdateInput,
  ) {
    return this.merchantService.updateOperationTime(opId, data)
  }
}
