import axios from 'axios'

describe('GET /customer/signIn', () => {
  beforeAll(() => {})
  it('should return a message', async () => {
    const res = await axios.get(`/api`)

    expect(res.status).toBe(200)
    expect(res.data).toEqual({ message: 'Hello API' })
  })
})
