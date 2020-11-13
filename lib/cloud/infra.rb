require "cloud/infra/version"
require 'redis'
require 'base64'
require 'json'
require 'net/http'

module Cloud
  module Infra
    class Client
      def has_entitlements_access?(identity_header, bundle)
        entitlements = entitlements(identity_header)
        entitlements&.dig(bundle, 'is_entitled') || false
      end

      def entitlements(identity_header)
        user = user_obj(identity_header)
        key = "user:#{user['user_id']}:entitlements"
        user_cache = redis_client.get(key)

        if user_cache
          entitlements = JSON.parse(user_cache)
        else
          rsp = call_cache_service(identity_header, nil, 'entitlements')
          entitlements = JSON.parse(rsp)
        end

        entitlements
      end

      def has_rbac_access?(identity_header, application, resource_type="*", verb="*")
        access = rbac_access(identity_header, application)
        access.any? { |a| a["permission"] == "#{application}:#{resource_type}:#{verb}" }
      end

      def rbac_access(identity_header, application)
        user = user_obj(identity_header)
        key = "user:#{user['user_id']}:rbac"
        user_cache = redis_client.hget(key, application)

        if user_cache
          access = JSON.parse(user_cache)
        else
          rsp = call_cache_service(identity_header, application, 'rbac')
          access = JSON.parse(rsp)
        end

        access
      end

      private

      def ttl(key)
        redis_client.ttl(key)
      end

      def user_obj(identity_header)
        decoded_identity(identity_header)['identity']['user']
      end

      def decoded_identity(identity_header)
        JSON.parse(Base64.decode64(identity_header))
      end

      def redis_client
        @redis_client ||= Redis.new(
          host: ENV['REDIS_HOST'] || '127.0.0.1',
          port: ENV['REDIS_PORT'] || 6379,
          db: ENV['REDIS_DB'] || 0,
          password: ENV['REDIS_PASSWORD']
        )
      end

      def call_cache_service(identity_header, application, cache_type)
        raise 'Cache type required.' unless cache_type
        base_url = "#{ENV['CACHE_HOST']}/api/platform-cache/cache"

        case cache_type
        when 'rbac'
          uri = URI("#{base_url}/rbac?application=#{application}")
        when 'entitlements'
          uri = URI("#{base_url}/entitlements")
        end

        req = Net::HTTP::Get.new(uri)
        req['x-rh-identity'] = identity_header

        res = Net::HTTP.start(uri.hostname, uri.port) {|http|
          http.request(req)
        }

        res.body
      end
    end
  end
end
