import { Module } from '@nestjs/common'
import { CustomerModule } from './customer/customer.module'
import { AdminModule } from './admin/admin.module'
import { GuardModule } from '@lugo/guard'
import { FirebaseModule } from '@lugo/firebase'
import { ConfigModule } from '@nestjs/config'
import { JwtModule } from '@nestjs/jwt'
import { UsersModule } from '@lugo/users'
import { JwtGuardModule } from '@lugo/jwtguard'

@Module({
  imports: [
    JwtModule.register({
      secret: 'App Secret',
      global: true,
    }),
    CustomerModule,
    AdminModule,
    GuardModule,
    FirebaseModule,
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    UsersModule,
    JwtGuardModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
