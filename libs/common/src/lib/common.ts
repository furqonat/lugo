import axios from 'axios'

export function str2obj(input?: unknown) {
  if (!input) {
    return undefined
  }
  if (Object.keys(input).length === 0) {
    return undefined
  }
  return input
    ? JSON.parse(JSON.stringify(input), (key, value) => {
        if (value === 'true' || value === 'false') {
          return value == 'true'
        } else if (
          typeof value === 'string' &&
          key !== '' &&
          value.startsWith('{')
        ) {
          return eval('(' + value + ')')
        } else {
          return value
        }
      })
    : undefined
}

export function toJson(input?: unknown) {
  return JSON.parse(
    JSON.stringify(
      input,
      (key, value) => (typeof value === 'bigint' ? value.toString() : value), // return everything else unchanged
    ),
  )
}

export function nameGenerator() {
  // generate unique name start with lugo
  return 'lugo' + Math.random().toString(36).substring(2)
}

export function otpGenerator() {
  // generate 6 digit otp
  return Math.floor(100000 + Math.random() * 900000)
}

export async function sendSms(phoneNumber: string, otp: string) {
  const resp = await axios.post(
    'https://console.zenziva.net/waofficial/api/sendWAOfficial/',
    {
      userkey: 'd0b112ded62a',
      passkey: 'e35637077be45d3ebb8c7985',
      to: phoneNumber,
      otp: otp,
      brand: 'Lugo',
    },
  )
  return resp.status
}
