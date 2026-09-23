# Raspberry Pi monitoring with Prometheus and Grafana

The complete configuration from the raspberry.tips guide: Prometheus, Grafana, Node Exporter and
cAdvisor on a Raspberry Pi, with four alert rules and push notifications to your phone.

- **Guide (English):** https://raspberry.tips/en/raspberrypi-tutorials/raspberry-pi-monitoring-prometheus-grafana-guide
- **Anleitung (Deutsch):** https://raspberry.tips/raspberrypi-tutorials/raspberry-pi-monitoring-prometheus-grafana

## Layout

```
compose.yaml                                        the whole stack, four containers
prometheus/prometheus.yml                           scrape targets
grafana/provisioning/datasources/datasource.yml     Prometheus data source, fixed uid
grafana/provisioning/alerting/alerts.yml            four alert rules (English)
grafana/provisioning/alerting/alerts_de.yml.example same rules, German titles
grafana/provisioning/alerting/contactpoints.yml     ntfy webhook with a templated payload
rpi_throttled.sh                                    vcgencmd throttling as Prometheus metrics
```

## Quick start

```
git clone https://github.com/raspberry-tips/raspberry-pi-monitoring.git
cd raspberry-pi-monitoring
```

Then, **before** the first start, enable the memory cgroup — without it no container memory can be
measured on Raspberry Pi OS. Append to the single line in `/boot/firmware/cmdline.txt`:

```
cgroup_enable=memory cgroup_memory=1
```

Reboot, put your own ntfy topic into `contactpoints.yml`, change the Grafana password in
`compose.yaml`, then:

```
docker compose up -d
```

## Things that are easy to get wrong

- **Node Exporter runs on the host network.** In a bridge network it reports the container's own
  interface instead of the Pi's, and every throughput panel measures the wrong thing.
- **cAdvisor is pinned to v0.55.1.** Newer GitHub releases exist, but the registry has no newer
  arm64 image — `:latest` fails with `no such manifest`.
- **Do not set your own `instance` label** in `prometheus.yml`. Dashboard 1860 filters on it and
  comes up completely empty.
- **Set the data source `uid` from the start.** Adding it to an already provisioned data source
  stops Grafana from starting at all.

The guide explains each of these in detail, with the measurements behind them.

## Versions

Tested on a Raspberry Pi 5 with Raspberry Pi OS (64-bit) and Docker 29.8.1 on 23 September 2026:
Prometheus v3.14.0, Grafana 13.2.2, Node Exporter v1.12.1, cAdvisor v0.55.1.
