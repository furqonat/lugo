import { Test, TestingModule } from '@nestjs/testing'
import { AdminController } from './admin.controller'
import { AdminService } from './admin.service'
import { PrismaService } from '@lugo/prisma'
import { FirebaseService } from '@lugo/firebase'
import { ConfigService } from '@nestjs/config'
import { BcryptService } from '@lugo/bcrypt'
import { JwtService } from '@nestjs/jwt'

describe('AdminController', () => {
  let controller: AdminController

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        AdminService,
        JwtService,
        PrismaService,
        BcryptService,
        FirebaseService,
        ConfigService,
      ],
    }).compile()

    controller = module.get<AdminController>(AdminController)
  })

  it('should be defined', () => {
    expect(controller).toBeDefined()
  })
})
