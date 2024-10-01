# Load necessary libraries
library(ggplot2)
library(sqldf)
library(dplyr)
library(tidyr)
options(scipen = 999)

# Read the data from CSV files
specs <- read.csv("./specs.csv")
iops <- read.csv("./../ssd/measurements/ssd_write_iops.csv")
packets <- read.csv("./../message_rate/measurements/packet.csv")

# Calculate the average packets per instance type
packets_avg <- sqldf("
  SELECT
    AVG(packets) AS packets,
    instance_type
  FROM packets
  GROUP BY instance_type
")

# Combine the data from specs, iops, and packets
combined <- sqldf("
  SELECT
    s.*,
    i.avg,
    i.instance_type AS iops_instance_type,
    p.packets
  FROM specs AS s
  JOIN iops AS i ON s.APIName = i.instance_type
  JOIN packets_avg AS p ON s.APIName = p.instance_type
")

# Calculate measured IOPS scaled by the number of SSDs
combined$measured_iops_scaled <- combined$avg * combined$SSDs

# Calculate SSD Bandwidth in Bytes/sec
combined$SSD_Bandwidth_BytesPerSec <- combined$measured_iops_scaled * 4096  # 1 MB = 1048576 Bytes

# Define message sizes in bytes
message_sizes <- c(256, 512, 1024, 2048, 4096, 8192)

# Expand the combined data for each message size
combined_expanded <- combined %>%
  crossing(MessageSize = message_sizes)

# Calculate SSD-limited Ops/sec for each message size
combined_expanded <- combined_expanded %>%
  mutate(SSD_limited_OpsPerSec = SSD_Bandwidth_BytesPerSec / MessageSize)

# Determine Max Ops/sec as the minimum of packets and SSD-limited Ops/sec
combined_expanded <- combined_expanded %>%
  mutate(Max_OpsPerSec = pmin(packets, SSD_limited_OpsPerSec))

# Calculate Ops per Dollar using the On-Demand price
combined_expanded <- combined_expanded %>%
  mutate(OpsPerDollar = (Max_OpsPerSec * 3600) / OnDemand)

# Normalize OpsPerDollar against the maximum value for each message size
combined_expanded <- combined_expanded %>%
  group_by(MessageSize) %>%
  mutate(Normalized_OpsPerDollar = OpsPerDollar / max(OpsPerDollar, na.rm = TRUE)) %>%
  ungroup()

# Optional: Plot the normalized Ops per Dollar against message sizes
ggplot(combined_expanded, aes(x = MessageSize, y = Normalized_OpsPerDollar, color = APIName)) +
  geom_line() +
  geom_point() +
  expand_limits(y=0) +
  scale_x_log10(breaks = message_sizes) +
  labs(
    title = "Normalized Ops per Dollar vs. Message Size",
    x = "Message Size (Bytes)",
    y = "Normalized Ops per Dollar"
  ) +
  theme_bw()
  

sqldf("SELECT AVG(Normalized_OpsPerDollar) as score, APIName FROM combined_expanded GROUP BY APIName ORDER BY score DESC")

