/* eslint-disable @next/next/no-img-element */
'use client'

import { customer } from '@prisma/client/users'
import { UrlService } from '../../services/url.service'
import { useSession } from 'next-auth/react'
import { useEffect, useState } from 'react'

interface User extends customer {
  _count: {
    order: number
    dana_token: number
  }
}

type Response = {
  data: User[]
  total: number
}

export function Users() {
  const [users, setUsers] = useState<Response | null>(null)
  const { data } = useSession()

  useEffect(() => {
    if (data?.user?.token) {
      const url = new UrlService(
        `${process.env.NEXT_PUBLIC_PROD_BASE_URL}account/admin/customer/`,
      )
        .addQuery('id', 'true')
        .addQuery('name', 'true')
        .addQuery('_count', '{select:{order:true, dana_token:true}}')
        .addQuery('status', 'true')
        .addQuery('avatar', 'true')
      fetch(encodeURI(url.build()), {
        headers: {
          Authorization: `Bearer ${data.user.token}`,
        },
      })
        .then((e) => e.json())
        .then(setUsers)
    }
  }, [data?.user?.token])

  console.log(users)
  return (
    <section>
      <div className="overflow-x-auto">
        <table className="table">
          {/* head */}
          <thead>
            <tr>
              <th>No</th>
              <th>Name</th>
              <th>Dana</th>
              <th>Total Order</th>
            </tr>
          </thead>
          <tbody>
            {/* row 1 */}
            {users?.data.map((item, index) => {
              return (
                <tr key={item.id}>
                  <th>{index + 1}</th>
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="avatar">
                        <div className="mask mask-squircle w-12 h-12">
                          <img
                            src={item.avatar ?? '/lugo.png'}
                            alt="Avatar Tailwind CSS Component"
                          />
                        </div>
                      </div>
                      <div>
                        <div className="font-bold">{item?.name}</div>
                        <div className="text-sm opacity-50">{item?.status}</div>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className="badge badge-ghost badge-sm capitalize">
                      {item._count.dana_token > 0 ? (
                        <span>Connected</span>
                      ) : (
                        <span>Not Connected </span>
                      )}
                    </span>
                  </td>
                  <td>{item._count?.order}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </section>
  )
}
