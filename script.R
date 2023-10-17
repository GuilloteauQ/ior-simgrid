# Read the data
library(tidyverse)
library(pajengr)

args = commandArgs(trailingOnly=TRUE)
infile = args[1]
outfile = args[2]

dta <- pajeng_read(infile)

# Manipulate the data
dta$state %>%
   # Remove some unnecessary columns for this example
   select(-Type, -Imbrication) %>%
   # Create the nice MPI rank and operations identifiers
   mutate(Container = as.integer(gsub("rank-", "", Container)),
          Value = gsub("^PMPI_", "MPI_", Value)) %>%
   # Rename some columns so it can better fit MPI terminology
   rename(Rank = Container,
          Operation = Value) -> df.states

# Draw the Gantt Chart
df.states %>%
   ggplot() +
   # Each MPI operation is becoming a rectangle
   geom_rect(aes(xmin=Start, xmax=End,
                 ymin=Rank,  ymax=Rank + 1,
                 fill=Operation)) +
   # Cosmetics
   xlab("Time [seconds]") +
   ylab("Rank [count]") +
   theme_bw(base_size=14) +
   theme(
     plot.margin = unit(c(0,0,0,0), "cm"),
     legend.margin = margin(t = 0, unit='cm'),
     panel.grid = element_blank(),
     legend.position = "top",
     legend.justification = "left",
     legend.box.spacing = unit(0, "pt"),
     legend.box.margin = margin(0,0,0,0),
     legend.title = element_text(size=10)) -> plot

 # Save the plot in a PNG file (dimensions in inches)
 ggsave(outfile,
        plot,
        width = 10,
        height = 3)
