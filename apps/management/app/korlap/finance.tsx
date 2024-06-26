/* eslint-disable @next/next/no-img-element */
'use client'

import { isSuperAdmin } from '../../services/app.service'
import { UrlService } from '../../services/url.service'
import {
  Prisma,
  admin,
  admin_wallet,
  driver,
  driver_details,
  referal,
  trx_admin,
} from '@prisma/client/users'
import {
  deleteObject,
  getDownloadURL,
  getStorage,
  ref,
  uploadBytes,
} from 'firebase/storage'
import { useSession } from 'next-auth/react'
import React, { useEffect, useRef, useState } from 'react'

type Driver = driver & {
  driver_details: driver_details
  _count: {
    order: number
  }
}

type Referal = referal & {
  _count: {
    driver: number
  }
  driver: Driver[]
}

type Admin = admin & {
  referal: Referal
  admin_wallet: admin_wallet
  trx_admin: trx_admin[]
}

export function Finance() {
  const { data } = useSession()
  const [admins, setAdmins] = useState<Admin | null>(null)

  useEffect(() => {
    if (data?.user?.token) {
      const url = new UrlService(
        process.env.NEXT_PUBLIC_ACCOUNT_BASE_URL + `admin/${data?.user?.id}`,
      )
        .addQuery('id', 'true')
        .addQuery('name', 'true')
        .addQuery('email', 'true')
        .addQuery('avatar', 'true')
        .addQuery('status', 'true')
        .addQuery('role', 'true')
        .addQuery('id_card', 'true')
        .addQuery('id_card_images', 'true')
        .addQuery('phone_number', 'true')
        .addQuery('admin_wallet', 'true')
        .addQuery('trx_admin', 'true')
        .addQuery('is_verified', 'true')
        .addQuery(
          'referal',
          '{select: { ref: true, driver: {include: {driver_details:true, _count: {select: {order:true}}}}, _count: {select: {driver: {where: {status: "ACTIVE"}}}}}}',
        )
      fetch(encodeURI(url.build()), {
        headers: {
          Authorization: `Bearer ${data?.user?.token}`,
        },
      })
        .then((e) => e.json())
        .then(setAdmins)
    }
  }, [data?.user?.token, data?.user?.id])
  return (
    <section className={'flex flex-col gap-6'}>
      {!isSuperAdmin(data) ? (
        <div className={'flex flex-row gap-6 w-full'}>
          <h2 className={'text-2xl font-semibold flex-1'}>My Stats</h2>
          <div>
            <RequestWidthdraw data={admins} />
          </div>
        </div>
      ) : null}
      <section className={'grid grid-cols-1 lg:grid-cols-2 gap-6'}>
        <div className={'flex flex-col gap-6'}>
          <section className={'grid grid-cols-2 gap-4'}>
            <div
              className={
                'stats stats-vertical shadow-sm border border-gray-200 border-solid'
              }
            >
              <div className="stat">
                <div className={'stat-title'}>My Balance </div>
                <div className={'stat-value text-2xl'}>
                  {admins?.admin_wallet?.balance != null
                    ? Number(admins?.admin_wallet?.balance)?.toLocaleString(
                        'id-ID',
                        {
                          style: 'currency',
                          currency: 'IDR',
                        },
                      )
                    : null}
                </div>
              </div>
            </div>
            <div
              className={
                'stats stats-vertical shadow-sm border border-gray-200 border-solid'
              }
            >
              <div className="stat">
                <div className={'stat-title'}>My Referal</div>
                <div className={'stat-value text-2xl'}>
                  {admins?.referal?._count?.driver}
                </div>
              </div>
            </div>
          </section>
          <section className={'grid grid-cols-1 gap-4'}>
            <div
              className={
                'stats stats-vertical shadow-sm border border-gray-200 border-solid'
              }
            >
              <div className={'flex flex-row items-center'}>
                <div className="stat flex-1">
                  <div className={'stat-title'}>My Referal </div>
                  <div className={'stat-value text-2xl'}>
                    {admins?.referal?.ref}
                  </div>
                </div>
                <button
                  className={'btn btn-ghost'}
                  onClick={(e) => {
                    navigator.clipboard.writeText(admins?.referal.ref ?? '')
                    alert('success copy to clipboard')
                  }}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    strokeWidth={1.5}
                    stroke="currentColor"
                    className="w-6 h-6"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75"
                    />
                  </svg>
                </button>
              </div>
            </div>
          </section>
          <h3 className={'font-semibold text-lg'}>Transactions history</h3>
          {admins &&
            admins?.trx_admin?.map((item) => {
              return (
                <div key={item.id} className={'card shadow-sm'}>
                  <div className={'card-body flex flex-row gap-6'}>
                    <div className={'flex-1'}>
                      <h3 className={'card-title'}>{item.trx_type}</h3>
                      <span>
                        {' '}
                        {new Date(item.created_at).toLocaleDateString('id-ID', {
                          year: 'numeric',
                          month: 'long',
                          day: '2-digit',
                        })}
                      </span>
                    </div>
                    <div>
                      <h3
                        className={`text-lg font-semibold ${
                          item.trx_type === 'WITHDRAW' ||
                          item.trx_type === 'REDUCTION'
                            ? 'text-red-400'
                            : 'text-green-400'
                        }`}
                      >
                        {Number(item.amount).toLocaleString('id-ID', {
                          style: 'currency',
                          currency: 'IDR',
                        })}
                      </h3>
                    </div>
                  </div>
                </div>
              )
            })}
        </div>
        <div>
          <table className="table">
            <thead>
              <tr>
                <th>No</th>
                <th>Name</th>
                <th>Address</th>
                <th>Total Jobs</th>
              </tr>
            </thead>
            <tbody>
              {admins &&
                admins?.referal?.driver?.map((item, index) => {
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
                            <div className="text-sm opacity-50">
                              {item.driver_details?.badge}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td>
                        {item.driver_details?.address}
                        <br />
                        <span className="badge badge-ghost badge-sm capitalize">
                          {item.driver_details?.driver_type.toLowerCase()}{' '}
                          Driver
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
    </section>
  )
}

function RequestWidthdraw(props: { data: Admin | null }) {
  const { data } = useSession()
  const ref = useRef<HTMLDialogElement>(null)

  const [amount, setAmount] = useState(0)

  function handleChangeAmount(e: React.ChangeEvent<HTMLInputElement>) {
    setAmount(e.target.valueAsNumber)
  }

  function handleOnSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const amountWallet = props.data?.admin_wallet.balance ?? 0
    if (amount > amountWallet) {
      alert('unable request widthdraw. balance is not enough')
      return
    } else {
      const body = {
        amount: amount,
      }
      const url = process.env.NEXT_PUBLIC_DEV_BASE_URL + '/portal/admin/wd'
      fetch(url, {
        method: 'POST',
        body: JSON.stringify(body),
        headers: {
          Authorization: `Bearer ${data?.user?.token}`,
          'Content-Type': 'application/json',
        },
      })
        .then((e) => e.json())
        .then(console.log)
    }
  }

  if (!props.data?.is_verified) {
    return <Verification data={props.data} />
  }

  return (
    <>
      <button
        className="btn btn-outline btn-sm"
        onClick={() => ref.current?.showModal()}
      >
        Request Widthdraw
      </button>
      <dialog ref={ref} className="modal">
        <div className="modal-box">
          <h3 className="font-bold text-lg">Request Witdhdraw</h3>
          <form onSubmit={handleOnSubmit} className={'flex flex-col gap-6'}>
            <label>
              <div className={'label'}>
                <span className={'label-text-alt'}>Amount</span>
              </div>
              <input
                className={'input input-sm input-bordered w-full'}
                value={amount}
                required={true}
                type={'number'}
                onChange={handleChangeAmount}
              />
            </label>
            <div className={'flex flex-row-reverse w-full gap-4'}>
              <button
                type={'button'}
                onClick={(e) => {
                  e.preventDefault()
                  ref.current?.close()
                }}
                className={'btn btn-outline btn-sm'}
              >
                Close
              </button>
              <button type={'submit'} className={'btn btn-sm btn-primary'}>
                Submit
              </button>
            </div>
          </form>
        </div>
      </dialog>
    </>
  )
}

function Verification(props: { data: Admin | null }) {
  const { data } = useSession()
  const dialogRef = useRef<HTMLDialogElement>(null)
  const fileRef = useRef<HTMLInputElement>(null)
  const [idCard, setIdCard] = useState(props.data?.id_card ?? '')
  const [idCardImage, setIdCardImage] = useState(
    props.data?.id_card_images ?? '',
  )
  const [phoneNumber, setPhoneNumber] = useState(props.data?.phone_number ?? '')
  function handleChangeIdCard(e: React.ChangeEvent<HTMLInputElement>) {
    setIdCard(e.target.value)
  }

  useEffect(() => {
    if (props.data) {
      setIdCard(props.data?.id_card ?? '')
      setIdCardImage(props.data?.id_card_images ?? '')
      setPhoneNumber(props.data?.phone_number ?? '')
    }
  }, [props.data])

  async function handleChangeIdCardImage(
    e: React.ChangeEvent<HTMLInputElement>,
  ) {
    const { files } = e.target
    if (idCardImage.startsWith('https')) {
      const refs = ref(getStorage(), idCardImage)
      deleteObject(refs).then(() => {})
    }
    const refs = ref(getStorage(), `verification/${files?.item(0)?.name}`)
    const data = await uploadBytes(refs, files?.item(0) as Blob)
    const url = await getDownloadURL(data.ref)
    setIdCardImage(url)
  }

  function handleChangePhoneNumber(e: React.ChangeEvent<HTMLInputElement>) {
    setPhoneNumber(e.target.value)
  }

  function handleOnSave(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const url =
      process.env.NEXT_PUBLIC_ACCOUNT_BASE_URL + `admin/${props.data?.id}`
    const body: Prisma.adminUpdateInput = {
      id_card: idCard,
      id_card_images: idCardImage,
      phone_number: phoneNumber,
    }
    fetch(url, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${data?.user?.token}`,
        'Content-type': 'application/json',
      },
      body: JSON.stringify(body),
    })
      .then((e) => e.json())
      .then(console.log)
  }

  function handleOnDeleteImage(e: React.MouseEvent<HTMLButtonElement>) {
    e.preventDefault()
    const refs = ref(getStorage(), idCardImage)
    deleteObject(refs).then((e) => {
      setIdCardImage('')
      fileRef.current!.value = ''
    })
  }

  return (
    <>
      <button
        className="btn btn-outline btn-sm"
        onClick={() => dialogRef.current?.showModal()}
      >
        Request Widthdraw
      </button>
      <dialog ref={dialogRef} className="modal">
        <div className="modal-box flex flex-col gap-6">
          <h3 className="font-bold text-lg">Verifications </h3>
          <form onSubmit={handleOnSave} className={'flex flex-col gap-4'}>
            <label>
              <div className={'label'}>
                <span className={'label-text-alt'}>ID Card Number</span>
              </div>
              <input
                placeholder={'0323xxxxxxx'}
                value={idCard}
                required={true}
                onChange={handleChangeIdCard}
                className={'input input-bordered input-sm w-full'}
              />
            </label>
            <label>
              <div className={'label'}>
                <span className={'label-text-alt'}>ID Card Images</span>
              </div>
              <input
                ref={fileRef}
                type={'file'}
                required={true}
                onChange={handleChangeIdCardImage}
                className={
                  'file-input file-input-bordered file-input-sm w-full'
                }
              />
            </label>
            {/* Preview image */}
            {idCardImage ? (
              <div className={'card w-full'}>
                <div className={'card-body'}>
                  <img src={idCardImage} alt={'ktp'} />
                  <div className={'card-actions'}>
                    <div className={'flex flex-row gap-6'}>
                      <button className={'btn-outline btn-sm btn'}>
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                          strokeWidth={1.5}
                          stroke="currentColor"
                          className="w-4 h-4"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
                          />
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                          />
                        </svg>
                      </button>
                      <button
                        className={'btn-outline btn-sm btn'}
                        onClick={handleOnDeleteImage}
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                          strokeWidth={1.5}
                          stroke="currentColor"
                          className="w-4 h-4"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                          />
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ) : null}
            <label>
              <div className={'label'}>
                <span className={'label-text-alt'}>Dana Phone Number</span>
              </div>
              <input
                placeholder={'0813xxxxx'}
                value={phoneNumber}
                required={true}
                type={'number'}
                onChange={handleChangePhoneNumber}
                className={'input input-bordered input-sm w-full'}
              />
            </label>
            <div className={'flex flex-row-reverse gap-6'}>
              <button
                type={'button'}
                className={'btn btn-sm'}
                onClick={() => dialogRef?.current?.close()}
              >
                Close
              </button>
              <button type={'submit'} className={'btn btn-sm btn-primary'}>
                Submit
              </button>
            </div>
          </form>
        </div>
      </dialog>
    </>
  )
}
