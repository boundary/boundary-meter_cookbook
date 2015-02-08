include Chef::DSL::DataQuery

class Chef
  class Resource
    class BoundaryMeter < Chef::Resource
      identity_attr :name

      def initialize(name, run_context=nil)
        super
        @resource_name = :boundary_meter
        @provider = Chef::Provider::BoundaryMeter
        
        @action = :create
        @allowed_actions.push(:create)
        @allowed_actions.push(:delete)
        
        @name = name
        @node_name = boundary_data('hostname')
        @token = boundary_data('token')
        
        @is_alt = false
        
        @discover_tags = boundary_data('discover_tags')
        @tags = []

        @conf_dir = nil
      end

      def conf_dir(arg=nil)
        # set_or_return :default => val doesn't seem to work?
        if arg == nil and @conf_dir == nil
          @conf_dir = conf_dir_default
        end
        
        set_or_return(:conf_dir, arg, :kind_of => [String])
      end

      def node_name(arg=nil)
        set_or_return(:node_name, arg, :kind_of => [String])
      end

      def token(arg=nil)
        set_or_return(:token, arg, :kind_of => [String])
      end

      def is_alt(arg=nil)
        set_or_return(:is_alt, arg, :kind_of => [TrueClass, FalseClass])
      end

      def discover_tags(arg=nil)
        set_or_return(:discover_tags, arg, :kind_of => [TrueClass, FalseClass])
      end

      def tags(arg=nil)
        # set_or_return :default => val doesn't seem to work?
        if arg == nil && @tags.empty?
          @tags = collect_tags
        end
        if arg.kind_of?(Array)
          arg.concat collect_tags
          arg.uniq!
        end
        set_or_return(:tags, arg, :kind_of => [Array])
      end

      private      

      def conf_dir_default
        if is_alt == true
          "%s_%s" % [Boundary::Meter::CONF_DIR, name]
        else
          Boundary::Meter::CONF_DIR
        end
      end

      def collect_tags
        collection = []

        # Chef Tags
        boundary_data('tags').each do |tag|
          collection.push tag
        end

        if discover_tags
          # EC2 Tags
          if node['ec2']
            node['ec2']['security_groups'].each do |group|
              collection.push group
            end

            if node['ec2']['placement_availability_zone']
              collection.push node['ec2']['placement_availability_zone']
            end

            if node['ec2']['instance_type']
              collection.push node['ec2']['instance_type']
            end
          end

          # OPSWorks Tags
          if node['opsworks']
            if node['opsworks']['stack']
              if node['opsworks']['stack']['name']
                collection.push node['opsworks']['stack']['name']
              end
            end

            if node['opsworks']['instance']
              node['opsworks']['instance']['layers'].each do |layer|
                collection.push layer
              end
            end

            node['opsworks']['applications'].each do |app|
              collection.push app['name']
              collection.push app['application_type']
            end
          end
        end

        collection
      end
    end
  end
end
