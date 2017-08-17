# Datadog primer

## Introduction
Datadog is a monitoring solution built to take on the new challenges of modern infrastructure and workloads. In this new landscape, gaining status and performance insights requires a new approach that takes into account the continuous state of flux of compute resources.

The explosion of software-as-a-service (SaaS) and the ubiquity of APIs have ushered in a new era of integrations. When considering the suitability of a new tool, the easiness of integration is one of the main factors to be evaluated. Datadog currently offers 200+ turn-key integrations and a simple SDK for rolling your own.

In this document, we will demonstrate how easy it is to go from zero to metrics reporting, dashboards and alerts for a single server, while laying down the groundwork to scale this solution to any number of hosts.

## The scenario
Our goal for this demonstration is to monitor the performance of db1, an on-premises Linux server running ubuntu, serving as a database (postgresql). We will capture system metrics, database-specific metrics by leveraging the Datadog Postgresql integration, and demonstrate the reporting of a custom metric.

We will then create dashboards for a better user experience while working with these metrics, and alerts to notify the operators of possible issues.

## Technical overview
### Preamble
For this demonstration, we will use [vagrant](https://vagrantup.com). Vagrant is a tool that allows us to replicate virtual environments based off a single configuration file. The technical details of the configuration can be found in the [appendix](#appendix)
```
$ vagrant init ubuntu/xenial64
### customize Vagrantfile
$ vagrant up
```
We now have a brand new ubuntu instance to be used in the subsequent steps.

### Subscribing for Datadog
Datadog provides a 15-day trial in which you can explore the platform at will, no credit card required. There are no limitations in terms of functionality available to a trial user.
Let's start by signing up for the service:
< screenshots here >
Take note of the API key. This secret key is what authenticates and authorizes your servers when using Datadog's APIs.

### Collecting data
In order to gather data from a host, we need a program (therefore called an Agent) that runs in the background and periodically records measurements we need. The Agent is also responsible for uploading the measurements to Datadog.
Since we already foresee the need to replicate the installation of the Datadog agent across multiple hosts in the future, we will leverage a configuration management tool (puppet) in order to create an easily repeatable procedure.
After running puppet and waiting for a few minutes, we can see our host reporting on datadog:
<screenshots here>

We will now install Postgresql and enable the corresponding Datadog integration, in order to get Postgresql specific metrics into Datadog:
<conf changes here>

At last, we will create a custom check to report on an arbitrary metric. For this example, we will simply generate a random number between zero and one and report that value:
<conf changes here>

To recap: in this section we covered how to get started with Datadog, leveraged a turn-key integration to report on our database, and configured the collection of a custom metric.
In this next section, we will see how to create functional dashboards to visualize this data.

### Visualizing your data
Now that db1 is gathering data and shipping it to Datadog, it is time to create some dashboards that allow us to use the data in a meaningful way.
Let's start by going to <some path in datadog>
<screenshot here>

Now we have a choice between a Timeboard and a Screenboard. There are substantial differences between the two, let's explore the Timeboard first.
<timeboard editor screenshot>
As we can see, there are many ways by which we can express a measurement, from single numbers to graphs and gauges. Let's add some measurements:
<timeboard editor screenshot>
We added some system metrics, like CPU/memory/disk usage, and also some database metrics, like connection pool usage and rate of inserts. Suppose an operator has to figure out why this database server is slow while performing queries, he/she could take one look at the Timeboard and figure out:
1. whether the slowness is caused by some system limits being hit, and if so:
2. whether it is high CPU usage, high memory usage, or disk I/O exceeding the provisioned IOPS

The reason why this is possible, is because all timeboards have a control that specifies the time window for the timeboard, and <b>all widgets on a timeboard are updated to reflect the currently selected time window</b>. This allows an operator to easily correlate distinct metrics and figure out trends or issues much faster.

Now assume, for the purpose of this exercise, that our test.support.random metric is a computed metric of overall healthiness of this system, and we would like a more general dashboard to showcase that. The Screenboard is probably the best fit for this purpose, since it differs from the Timeboard in three crucial ways: 
1. it allows widgets to be placed in a free-form way,
2. it provides us with different widgets, like the event stream and embedded iframes, and
3. it allows us to <b>set the time window per widget</b>.

Let's see what that looks like:
<screenshots (more than one)>

Screenboards can also be shared publically. To see this screenboard live on datadog, click [here]().

In this section we covered how to visualize your data and some of the different ways to do so.
We will now see how to configure Datadog to take actions when certain conditions are met.

### Alerting on your data
Operations teams leverage metric collection systems in many ways, and one of the most important features is the ability to automatically notify an operator when a certain metric exceeds a threshold. This enables operation teams to respond swiftly in case of issues, guaranteeing business continuity.

In the last section, we defined test.support.random to be an overall indicator of system health. Let's create an alert and specify the appropriate conditions to notify the operations team their immediate attention is needed.
This synthetic measurement a minimum value of 0 and a maximum of 1. For the purposes of this exercise, we assume that the higher the score, the more unhealthy the system is. We will configure the alert to trigger if this metric exceeds 0.90 at least once, during the last 5 minutes.
<screenshots here>

Datadog also allows us to customize the email message:
<editor screenshot>

All we have to do is wait a little, and voila:
<email screenshot>

This is just a test system, and considering the way we set up test.support.random, there's a 10% chance the alert will be triggered on each check (which happens approximately every 20 seconds). We probably don't want to notify our operators after business hours then:
<screenshot scheduled downtime>

Datadog will then notify the operators, once, on the scheduled downtime:
<email screenshot here>

In this section we briefly showcased one way to trigger actions (alerting) upon fulfilling some predefined conditions on certain metrics.

## Conclusion
This concludes our brief introduction to Datadog. In this document we covered the basics, which should empower new users to get up to speed with the platform. This is by no means a comprehensive guide, however. We provide many [guides]() and [videos](https://docs.datadoghq.com/videos/) that cover basic elements like gathering data to advanced topics such as creating new integrations, doing autodiscovery with containers and single sign-on.

For the technical details on the sample scenario discussed in the document, check the [Appendix](#appendix) section.

## Appendix
### Level 0 - Setup an Ubuntu VM
I used puppet to install and configure both Postgresql and the Datadog agent. First, I installed the appropriate puppet modules into the target folder:
```
$ puppet module install -i ./modules datadog-datadog_agent
Notice: Preparing to install into .../modules ...
Notice: Created target directory .../modules
Notice: Downloading from https://forgeapi.puppet.com ...
Notice: Installing -- do not interrupt ...
/.../modules
└─┬ datadog-datadog_agent (v1.11.0)
  ├── lwf-remote_file (v1.1.3)
  ├── puppetlabs-concat (v2.2.0)
  ├── puppetlabs-ruby (v0.6.0)
  └── puppetlabs-stdlib (v4.18.0)
$ puppet module install -i ./modules puppetlabs-postgresql
Notice: Preparing to install into /.../modules ...
Notice: Downloading from https://forgeapi.puppet.com ...
Notice: Installing -- do not interrupt ...
/.../modules
└─┬ puppetlabs-postgresql (v5.1.0)
  ├── puppetlabs-apt (v4.1.0)
  ├── puppetlabs-concat (v2.2.0)
  └── puppetlabs-stdlib (v4.18.0)
```

I used `vagrant init` to get a sample Vagrantfile, and then [configured it](../vm/Vagrantfile) to bootstrap the machine by installing the puppet agent, and [running puppet with my manifest afterwards](../vm/environments/test/default.pp):

With this in place, I used `vagrant up` to bring the machine up.

### Level 1 - Collecting your data
I signed up for DataDog using my email, and retrieved the API key for the agent.

Bonus question: The agent is a program that runs in the background, polling for metrics at set intervals and uploading said metrics to Datadog. It also includes DogStatsD, a custom StatsD implementation that allows metric gathering via push, and metric aggregation prior to forwarding the metrics upstream.


