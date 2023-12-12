import {
  Body,
  Controller,
  Get,
  Headers,
  Put,
  Query,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common'
import { CustomerBasicUpdate, CustomerQuery } from '../dto/customer.dto'
import { CustomerService } from './customer.service'
import { str2obj } from '@lugo/common'
import { Role, Roles, RolesGuard } from '@lugo/guard'

@UseGuards(RolesGuard)
@Controller('customer')
export class CustomerController {
  constructor(private readonly customerService: CustomerService) {}

  @Roles(Role.USER)
  @Get()
  async getCustomer(
    @Headers('Authorization') token?: string,
    @Query() query?: CustomerQuery,
  ) {
    if (token) {
      return this.customerService.getCustomer(token, str2obj(query))
    } else {
      throw new UnauthorizedException()
    }
  }

  @Roles(Role.USER)
  @Put()
  async basicUpdateCustomer(
    @Body() data: CustomerBasicUpdate,
    @Headers('Authorization') token?: string,
  ) {
    if (token) {
      return this.customerService.basicUpdate(token, data)
    } else {
      throw new UnauthorizedException()
    }
  }
}
