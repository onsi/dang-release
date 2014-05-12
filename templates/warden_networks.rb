# Each Warden container is a /30 in Warden's network range, which is
# configured as 10.244.0.0/22. There are 256 available entries.

require "yaml"
require "netaddr"

dang1_subnets = []
dang1_start = NetAddr::CIDR.create("10.244.22.0/30")

dang2_subnets = []
dang2_start = NetAddr::CIDR.create("10.244.24.0/30")

dang3_subnets = []
dang3_start = NetAddr::CIDR.create("10.244.26.0/30")

128.times do
  dang1_subnets << dang1_start
  dang1_start = NetAddr::CIDR.create(dang1_start.next_subnet)

  dang2_subnets << dang2_start
  dang2_start = NetAddr::CIDR.create(dang2_start.next_subnet)

  dang3_subnets << dang3_start
  dang3_start = NetAddr::CIDR.create(dang3_start.next_subnet)
end

puts YAML.dump(
  "networks" => [
    { "name" => "dang1",
      "subnets" => dang1_subnets.collect.with_index do |subnet, idx|
        { "cloud_properties" => {
            "name" => "random",
          },
          "range" => subnet.to_s,
          "reserved" => [subnet[1].ip],
          "static" => idx < 64 ? [subnet[2].ip] : [],
        }
      end
    },
    { "name" => "dang2",
      "subnets" => dang2_subnets.collect.with_index do |subnet, idx|
        { "cloud_properties" => {
            "name" => "random",
          },
          "range" => subnet.to_s,
          "reserved" => [subnet[1].ip],
          "static" => idx < 64 ? [subnet[2].ip] : [],
        }
      end
    },
    { "name" => "dang3",
      "subnets" => dang3_subnets.collect.with_index do |subnet, idx|
        { "cloud_properties" => {
            "name" => "random",
          },
          "range" => subnet.to_s,
          "reserved" => [subnet[1].ip],
          "static" => idx < 64 ? [subnet[2].ip] : [],
        }
      end
    },
  ])
