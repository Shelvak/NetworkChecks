require 'yaml'
require 'mtik'
require 'amazing_print'
require 'active_support/all'

module NetworkChecks
  # will improve...
  extend self

  CONFIG = YAML.safe_load(
    File.read(
      File.expand_path('../config.yml', __dir__)
    )
  ).deep_symbolize_keys

  INTERNAL_IPS = CONFIG[:internal_ips]

  def mkt_connection
    @connection ||= ::MTik::Connection.new(
      NetworkChecks::CONFIG[:mikrotik].slice(:host, :user, :pass, :port).merge(
        conn_timeout:         15,
        cmd_timeout:          15,
        ssl:                  false,
        unecrypted_plaintext: true
      )
    )
  end

  def close_connector!
    return unless @connector.present?
    @connector.close!
    @connector = nil
  end

  def getall(command)
    mkt_connection.get_reply(command, ['detail']).map do |resp|
      resp.delete('!re')
      resp.delete('!done')
      resp.delete('.tag')

      next if resp.empty?

      if resp.key?('message') && !command.start_with?('/log')
        {
          status: false,
          response: resp
        }
      else
        parsed_hash = {}

        resp.each do |key, value|
          if ['ret', '.id'].include?(key)
            parsed_hash[:mk_id] = value.delete('*')
          else
            parsed_hash[key.underscore.to_sym] =  value.to_s.force_encoding('ISO-8859-1').encode('utf-8')
          end
        end

        {
          status: true,
          response: parsed_hash.deep_symbolize_keys
        }
      end
    end.compact
  end

  def list_wifi_clients
    leases = getall('/ip/dhcp-server/lease/getall').map { |e| [e[:response][:mac_address], e[:response]] if e[:response]}.compact.to_h.select do |mac_address, body|
      body[:disabled] == 'false'
    end.compact.to_h

    clients = getall('/caps-man/registration-table/getall').map { |e| e[:response] }.compact

    clients.each_with_object({}) do |w_client, memo|
      client = leases[w_client[:mac_address]] || {}
      name = client[:comment].presence || client[:host_name] || w_client[:host_name]
      memo[name] = client.merge(w_client).slice(
        :interface, :address, :mac_address, :tx_rate, :rx_rate, :rx_signal, :uptime,:host_name, :comment,
      )
    end
  end

  def pingear
    # ping fotocopia.frm.utn.edu.ar
    # ping netflix.com
    # ping digitalocean.com
    # ping 8.8.8.8
    # ping 209.97.144.177
  end

  def iperf
    # iperf server /
  end

  def satura
   # o speedtest
  end
  def logs
    getall('/log/getall').last(100).map {|e| [e[:response][:time], e[:response][:message]].join(' - ')}.compact
  end
end
