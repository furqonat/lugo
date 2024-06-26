import { FirebaseService } from '@lugo/firebase'
import { PrismaService } from '@lugo/prisma'
import { BadRequestException, NotFoundException } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import { Test, TestingModule } from '@nestjs/testing'
import { DriverController } from './driver.controller'
import { DriverService } from './driver.service'

describe('DriverController', () => {
  let controller: DriverController
  let getDriverMock: jest.Mock
  let applyDriverMock: jest.Mock

  beforeEach(async () => {
    getDriverMock = jest.fn()
    applyDriverMock = jest.fn()
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DriverController],
      providers: [
        FirebaseService,
        ConfigService,
        PrismaService,
        {
          provide: DriverService,
          useValue: {
            getDriver: getDriverMock,
            applyDriver: applyDriverMock,
          },
        },
      ],
    }).compile()

    controller = module.get<DriverController>(DriverController)
  })

  it('should be defined', () => {
    expect(controller).toBeDefined()
  })

  describe('get driver without select', () => {
    const driver = { id: '123456' }
    beforeEach(() => {
      getDriverMock.mockReturnValue(driver)
    })

    it('test get driver without select', async () => {
      const result = await controller.getDriver({ uid: '123456' })
      expect(result.id).toBe(driver.id)
    })
  })

  describe('get driver with select', () => {
    const driver = { id: '123456', name: 'test driver' }
    beforeEach(() => {
      getDriverMock.mockReturnValue(driver)
    })

    it('test get driver with select', async () => {
      const result = await controller.getDriver(
        { uid: '123456' },
        {
          id: true,
          name: true,
        },
      )
      expect(result.id).toBe(driver.id)
      expect(result.name).toBe(driver.name)
    })
  })

  describe('get driver and return not found', () => {
    beforeEach(() => {
      getDriverMock.mockReturnValue(undefined)
    })

    it('test get driver and return not found', async () => {
      try {
        await controller.getDriver({ uid: '' }, { name: true })
      } catch (e) {
        expect(e).toBeInstanceOf(NotFoundException)
      }
    })
  })

  describe('apply driver and return OK', () => {
    const response = {
      message: 'OK',
      res: '123456',
    }
    beforeEach(() => {
      applyDriverMock.mockReturnValue(response)
    })

    it('test apply driver and return OK', async () => {
      const result = await controller.applyToBeDriver(
        { uid: '1231' },
        {
          address: '',
          license_image: '',
          id_card_image: '',
        },
      )
      expect(result.res).toBe(response.res)
      expect(result.message).toBe(response.message)
    })
  })

  describe('apply driver and return bad request', () => {
    beforeEach(() => {
      applyDriverMock.mockReturnValue(undefined)
    })

    it('test apply driver and return bad request', async () => {
      try {
        controller.applyToBeDriver(
          { uid: '12312' },
          {
            address: '',
            license_image: '',
            id_card_image: '',
          },
        )
      } catch (e) {
        expect(e).toBeInstanceOf(BadRequestException)
      }
    })
  })
})
