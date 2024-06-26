'use client'

import { usePathname } from 'next/navigation'
import React from 'react'
import { Navbar, Sidebar } from '../components'
import { SessionProvider } from 'next-auth/react'
import { FirebaseProvider } from './firebase.provider'

type ProviderType = {
  children: React.ReactNode
}
export function PageProvider({ children }: ProviderType) {
  const pathname = usePathname()
  return (
    <SessionProvider>
      <FirebaseProvider>
        <div className={'overflow-hidden'}>
          {!pathname.startsWith('/auth') ? (
            <div className={'flex max-h-screen'}>
              <div
                className={
                  'hidden md:flex flex-col overflow-y-scroll hide-scrollbar min-h-screen'
                }
              >
                <Sidebar />
              </div>
              <div className={'flex flex-col flex-1 overflow-y-scroll'}>
                <Navbar />
                {children}
              </div>
            </div>
          ) : (
            children
          )}
        </div>
      </FirebaseProvider>
    </SessionProvider>
  )
}
