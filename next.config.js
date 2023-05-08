/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  rewrites: async () => {
    return [
      {
        source: "/",
        destination: "/index.html",
      }
    ]
  }
}



module.exports = nextConfig
