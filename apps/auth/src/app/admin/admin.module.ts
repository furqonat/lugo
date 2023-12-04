import { BcryptModule, BcryptService } from '@lugo/bcrypt'
import { UsersPrismaService } from '@lugo/users'
import { Module } from '@nestjs/common'
import { JwtModule, JwtService } from '@nestjs/jwt'
import { AdminController } from './admin.controller'
import { AdminService } from './admin.service'
import { ConfigModule } from '@nestjs/config'

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      global: true,
    }),
    BcryptModule,
  ],
  providers: [AdminService, UsersPrismaService, BcryptService, JwtService],
  controllers: [AdminController],
})
export class AdminModule {}
