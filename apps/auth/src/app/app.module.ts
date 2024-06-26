import { Module } from '@nestjs/common'

import { BcryptModule } from '@lugo/bcrypt'
import { FirebaseModule } from '@lugo/firebase'
import { GuardModule } from '@lugo/guard'
import { PrismaModule } from '@lugo/prisma'
import { ConfigModule } from '@nestjs/config'
import { AdminModule } from '../admin/admin.module'
import { CustomerModule } from '../customer/customer.module'
import { DriverModule } from '../driver/driver.module'
import { MerchantModule } from '../merchant/merchant.module'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    CustomerModule,
    MerchantModule,
    DriverModule,
    AdminModule,
    PrismaModule,
    FirebaseModule,
    BcryptModule,
    GuardModule,
  ],
})
export class AppModule {}
