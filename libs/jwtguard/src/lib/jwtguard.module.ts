import { Module } from '@nestjs/common'
import { APP_GUARD } from '@nestjs/core'
import { JwtService } from '@nestjs/jwt'
import { RolesGuard } from './roles.guard'

@Module({
  controllers: [],
  providers: [
    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },
    JwtService,
  ],
  exports: [],
})
export class JwtGuardModule {}
