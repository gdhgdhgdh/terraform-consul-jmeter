terraform-consul-jmeter
=======================

JMeter is a tremendously useful tool for performing load testing since it works
well in distributed environments. Regrettably it is also pain in the backside
to deploy because it has an ancient UNIX-wizard imbued idea that all IP
devices have lovely clean unfiltered access between each other.

Remember when [fingering] someone across the Internet only caused college
freshmen to giggle?

Anyway, the concepts of NAT and firewalls seem completely alien to JMeter. As a result,
deployment often involves (ab)using SSH tunnels [like this].

I actually had a business need to run a distributed JMeter and thought it
would be a great opportunity to use a few new technologies:

### Docker

If you don't know what this is by now, your hype-ignoring gland is working
exceptionally well.

### Weave

A provider-agnostic networking overlay for Docker containers (and their hosts) - [weave]

### Terraform

A provider-agnostic Infrastructure-As-Code tool for cloud providers by the happy people at [Hashicorp]. Its goal
is to be 'CloudFormation for everybody else' if that helps.

### Consul

A key-value store also from Hashicorp - we're using their public demo instance at http://demo.consul.io/ -
please be aware that its contents get reset half-hourly so I recommend you run the
first `terraform apply` just after the hour or half-hour.

## Technical implementation

Several AWS instances will be launched and joined into a simple `10.0.1.0/24`
network where the first instance will run the JMeter client and act as the
control point for the cluster on `10.0.1.254`.

Each subseqent AWS instance will call home to the public IP of the client
instance in order to get an IP address (check out my terrible one-line web
service using netcat and bash on line 17 of [user-data-client]) so that its
IP address on the Weave network can be initialised. It would be awesome if
Weave supported DHCP. It doesn't.

When each of these instances ask for the next available IP, the aforementioned
terrible one-line web service will update the JMeter config file so the JMeter
client knows which server worker IPs are available. It doesn't deal with servers
going away and coming back on a new IP. This is a proof of concept.

## Light the blue touchpaper and retire to a safe distance

1. Create / import an SSH keypair to each region that you want to run instances in.
This isn't really needed for production usage, but it's nice if you want to poke around
the instances and see what's going on. My guess if you're reading about this work, then
that's how your mind works.
1. Edit the `terraform.tfvars` in both the `client/` and `server/` directories
so they contain your AWS access and secret keys - we will be creating and destroying
instances, VPCs, and security groups, so at least the IAM 'Power User' template
is desirable. Also include the IP address from which you will launch any SSH or VNC access
to the launched instances. (It's usually https://www.google.co.uk/?gws_rd=ssl#q=ip with a /32 suffix)
1. Wait until one minute past the (half) hour since the public Consul demo site is regularly reset.
1. `cd client`
1. `terraform plan` to see what Terraform will do. This is an awesome feature
just by itself since Amazon's own [CloudFormation] tool has no such facility.
1. `terraform apply` to make it go. It will default to creating two EC2 instances
in the `eu-west-1` region.
1. Get the public IP of the client instance from http://demo.consul.io/ui/#/nyc3/kv/weave_jmeter_gdh/serverip/edit
Yes I called it 'serverip' and that's a terrible name.
1. Launch a VNC Viewer against that IP address. Windows users might want [TightVNC_Viewer] since it's GPL'd
and won't install crapware or beg you to buy a commercial upgrade.
1. `u: ubuntu p: terraform`
1. Launch Start -> Programming -> Apache JMeter and observe the Run -> Remote Start menu should be populated with
the number of server instances - two unless you changed the defaults - on 10.1.1.1 and 10.1.1.2.
1. Upload a JMX test definition file and use JMeter to your heart's content

Now let's try launching additional instances. Bear in mind because we are using
Weave for the network overlay that any additional instances could be on Digital
Ocean, Google Compute Engine, your home server or anywhere else that can run
Linux and Docker. I think that's pretty awesome.

For our purposes we're just going to launch stuff in a different AWS Region
because it simplifies the configuration and the number of variables needed.

1. You've been working in the `client/` directory up to now, so let's `cd ../server`
1. `terraform plan` as before - once again we're going to create a new VPC
and two instances to sit inside.
1. `terraform apply`
1. Back on the VNC session to the client, quit and reload JMeter every few minutes
and you should eventually see the Run -> Remote Start menu populate with more servers
in the `10.0.1.0/24` CIDR block. Every machine in that network can reach each other.

Feedback / PR's welcome!

Cheers,
Gavin.


[TightVNC_Viewer]:http://www.tightvnc.com/download/1.3.10/tightvnc-1.3.10_x86_viewer.zip
[CloudFormation]:http://aws.amazon.com/cloudformation/
[user-data-client]:https://github.com/gdhgdhgdh/terraform-consul-jmeter/blob/master/client/user_data_client.txt#L17
[fingering]:https://kb.iu.edu/d/aasp
[like this]:https://cloud.google.com/developers/articles/how-to-configure-ssh-port-forwarding-set-up-load-testing-on-compute-engine/
[Hashicorp]:https://www.terraform.io/
[weave]:https://github.com/zettio/weave#readme

