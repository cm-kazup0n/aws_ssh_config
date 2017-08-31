require 'aws'


module EC2

    # EC2インスタンス一覧を取得する
    # 踏み台インスタンスを取得する -> 普通のホスト設定
    # ターゲットインスタンスを取得する -> 踏み台経由設定
    # 鍵が同じのどうしを紐付けする

    class Instance 

        def initialize(name:, private_hostname:, keyname:, public_hostname: nil)
            @name = name
            @private_hostname = private_hostname
            @keyname = keyname
            @public_hostname = public_hostname
        end

        def bastion?
            @name.include?("bastion")
        end

        def solitary?
            @public_hostname.nil?
        end

    end

    class InstanceList

        def initialize(instances)
            @instances = instances
        end

        def bastions
            tup = @instances.select(&:bastion?).map{|instance| [instance.keyname, instance]}
            Hash[*tup.flatten]
        end

        def solitaries
            @instances.select(&:solitary?)
        end

    end


    module ConfigGenMixin
        def eval(&block)
            Nymphia::DSL::Context.new(&block)
        end
    end

    module BastionConfigGenMixin

        def gen(instance)

            host instance.name do
                hostname instance.public_hostname
                user 'ec2-user'
                identity_file instance.keyname.to_sym, "~/.ssh/#{instance.keyname}.pem"
                use_identity_file instance.keyname.to_sym
            end
        end

    end


    
end