import { PrismaClient } from '@prisma/client/users'
import * as bcrypt from 'bcrypt'
const prisma = new PrismaClient()
async function main() {
  await prisma.roles.createMany({
    data: [
      {
        id: 'spradmin-1',
        name: 'SUPERADMIN'
      }, {
        id: 'spradmin-2',
        name: 'ADMIN'
      },
      {
        id: 'koral-1',
        name: 'KORLAP',
      },
      {
        id: 'korcap-1s',
        name: 'KORCAP'
      }
    ],
  })

  // await prisma.company_balance.create({
  //   data: {
  //     balance: 0,
  //     id: 'LUGO_BALANCE'
  //   }
  // })

  await prisma.admin.create({
    data: {
      name: 'Furqon Romdhani',
      email: 'furqon@gmail.com',
      password: bcrypt.hashSync('test123', 10),
      role: {
        connect: {
          id: 'spradmin-1'
        }
      }
    }
  })
  await prisma.admin.create({
    data: {
      name: 'Alicia Hamdono',
      email: 'alicia@gmail.com',
      password: bcrypt.hashSync('test123', 10),
      role: {
        connect: {
          id: 'spradmin-2'
        }
      }
    }
  })
  await prisma.admin.create({
    data: {
      name: 'Ahmad Mulyanto',
      email: 'mulyanto@gmail.com',
      password: bcrypt.hashSync('test123', 10),
      role: {
        connect: {
          id: 'koral-1'
        }
      },
      referal: {
        create: {
          ref: 'lugo321'
        }
      }
    }
  })
  await prisma.customer.create({
    data: {
      name: "Dadan Hermawan",
      email: 'test@example.com'
    }
  })
  await prisma.merchant.create({
    data: {
      name: "Ahmad Sutoyo",
      email: 'testmerch@example.com',
      type: 'FOOD',
      details: {
        create: {
          name: "Frozen Food Ahmad",
          address: "JL. RAYA CINTA",
          id_card_image: "https://awsimages.detik.net.id/community/media/visual/2017/07/20/3a1c67e8-064d-4f56-80eb-feced76cad3e_169.jpg?w=600&q=90",
          images: {
            createMany: {
              data: [
                {
                  link: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgf5hI70HM4O0v5X2JJuqvRSzFkrGq2EhWtGWXlsXqoDG3fg2FqBULh5M8l1r87_xcvHxHl0bZL8pG_bOT6-9xTMvifdajC2KkjLJNLSa1IMji-R9FVuoNHZBVWcFUbSPIDXz9cVk5bkEOu7jxK7BGWimd0e-CJ6RIxt17itptD-ukCyFk7pKAOd2NmcuSt/w1200-h630-p-k-no-nu/TOKO%20AGEN%20FROZEN%20FOOD%20TERDEKAT%20DARI%20LOKASI%20SAYA.jpg'
                },
                {
                  link: 'https://img.ws.mms.shopee.co.id/52e90edb1f4e9c7f42711855e12bd178'
                }
              ]
            }
          }
        }
      }
    }
  })
  await prisma.driver.create({
    data: {
      name: "Jajang Mulyana",
      email: 'test@example.com',
      phone: "+62812345678911",
      driver_details: {
        create: {
          id_card_image: "https://d39wptbp5at4nd.cloudfront.net/media/5883_original_20151219_134407-1.jpg",
          license_image: "https://imgx.motorplus-online.com/crop/0x0:0x0/360x240/photo/2023/08/14/sim-mati-bisa-diperpanjangjpg-20230814110653.jpg",
          address: "PASANGRAHAN JL. JALAN CINTA",
          driver_type: "BIKE",
          vehicle: {
            create: {
              vehicle_brand: "Supra Bapack",
              vehicle_image: "https://imgx.gridoto.com/crop/0x0:0x0/750x500/photo/2022/04/21/modifikasi-honda-supra-xjpg-20220421034504.jpg",
              vehicle_registration: "https://cdn1-production-images-kly.akamaized.net/39pgx7jUflWuG2zAEqdPf71n-9g=/800x450/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/1120096/original/031978500_1453535112-STNK.jpg",
              vehicle_rn: "RI 1",
              vehicle_type: "BIKE",
              vehicle_year: "2023"
            }
          }
        }
      },
      referal: {
        connect: {
          ref: "lugo321"
        }
      }
    }
  })

}

main().then(() => {
  console.log('database seeded')
}).catch((e) => {
  throw new Error(e)
})
