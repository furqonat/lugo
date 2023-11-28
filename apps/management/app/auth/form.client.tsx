'use client'

import React, { useState } from 'react'
import { signIn } from 'next-auth/react'
import { useRouter } from 'next/navigation'
import { ToastContainer, toast } from 'react-toastify'
import 'react-toastify/ReactToastify.min.css'

export function Form() {
  const [visible, setVisible] = useState(false)
  const [loading, setLoading] = useState(false)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const router = useRouter()

  function handleChangeEmail(e: React.ChangeEvent<HTMLInputElement>) {
    setEmail(e.target.value)
  }

  function handleChangePassword(e: React.ChangeEvent<HTMLInputElement>) {
    setPassword(e.target.value)
  }

  function handleClickVisible(e: React.MouseEvent<HTMLButtonElement>) {
    e.preventDefault()
    setVisible(!visible)
  }

  function handleSubmitForm(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setLoading(true)
    signIn('credentials', {
      email: email,
      password: password,
      redirect: false,
    })
      .then((resp) => {
        setLoading(false)
        if (resp?.error) {
          if (!toast.isActive('error')) {
            toast.error('username atau password salah', {
              toastId: 'error',
            })
          }
        } else {
          setLoading(false)
          router.push('/')
        }
      })
      .catch(() => {
        setLoading(false)
      })
  }
  return (
    <form
      onSubmit={handleSubmitForm}
      className={'form-control flex flex-col gap-5'}
    >
      <div>
        <label htmlFor={'email'} className={'label'}>
          <span className={'label-text'}>Email</span>
        </label>
        <input
          className={'input input-bordered input-md w-full'}
          placeholder={'Enter your email address'}
          name={'email'}
          type={'email'}
          value={email}
          autoComplete={'email'}
          onChange={handleChangeEmail}
          min={5}
          required={true}
        />
      </div>
      <div>
        <label htmlFor={'password'} className={'label'}>
          <span className={'label-text'}>Password</span>
        </label>
        <div className={'join'}>
          <input
            className={'input input-bordered input-md join-item'}
            placeholder={'Enter your password'}
            name={'password'}
            type={visible ? 'text' : 'password'}
            value={password}
            onChange={handleChangePassword}
            required={true}
            min={6}
            autoComplete={'current-password'}
          />
          <button
            type={'button'}
            onClick={handleClickVisible}
            className={'join-item btn btn-square btn-md'}
          >
            {!visible ? (
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
                  d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
            ) : (
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
                  d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"
                />
              </svg>
            )}
          </button>
        </div>
      </div>
      <div>
        <button type={'submit'} className={'btn btn-primary'}>
          {loading ? <span className={'loading loading-spinner'} /> : null}
          Sign In
        </button>
      </div>
      <ToastContainer />
    </form>
  )
}