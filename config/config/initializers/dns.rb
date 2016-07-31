class << Resolv
	#speed connect time
  def use_google_dns
    remove_const :DefaultResolver
    const_set :DefaultResolver, self.new(
      [Resolv::Hosts.new, Resolv::DNS.new(nameserver: ['8.8.8.8', '8.8.4.4'], search: ['mydns.com'], ndots: 1)]
    )
  end

end

Resolv.use_google_dns
require 'resolv-replace'

