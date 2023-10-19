/* Copyright (c) 2009-2023. The SimGrid Team. All rights reserved.          */

/* This program is free software; you can redistribute it and/or modify it
 * under the terms of the license (GNU LGPL) which comes with this package. */

#include "xbt/replay.hpp"
#include <simgrid/s4u/Actor.hpp>
#include "smpi/smpi.h"
#include "xbt/asserts.h"
#include "xbt/str.h"
#include <boost/algorithm/string/join.hpp>
#include "simgrid/plugins/file_system.h"
#include "simgrid/s4u.hpp"

#include "xbt/log.h"
XBT_LOG_NEW_DEFAULT_CATEGORY(replay_test, "Messages specific for this example");

std::unordered_map<std::string, simgrid::s4u::File*> opened_files;


/* This shows how to extend the trace format by adding a new kind of events.
   This function is registered through xbt_replay_action_register() below. */
static void action_io_write(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Writing");
    std::string filename     = args[2];
    auto* file               = opened_files[filename];
    long int io_size = std::atof(args[3].c_str());
    sg_size_t write = file->write(io_size);
}

static void action_io_write_at(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Writing At");
    std::string filename     = args[2];
    long long offset = std::atof(args[3].c_str());
    auto* file               = opened_files[filename];
    file->seek(offset, SEEK_SET);
    long int io_size = std::atof(args[4].c_str());
    sg_size_t write = file->write(io_size);
}

static void action_io_read(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Reading");
    std::string filename     = args[2];
    auto* file               = opened_files[filename];
    long int io_size = std::atof(args[3].c_str());
    sg_size_t read = file->read(io_size);
}

static void action_io_read_at(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Reading At");
    std::string filename     = args[2];
    long long offset = std::atof(args[3].c_str());
    auto* file               = opened_files[filename];
    file->seek(offset, SEEK_SET);
    long int io_size = std::atof(args[4].c_str());
    sg_size_t read = file->read(io_size);
}

static void action_io_open(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Openning");
    std::string filename     = args[2];
    int amode = std::atof(args[3].c_str());
    if (amode & MPI_MODE_APPEND) {
        auto* file               = opened_files[filename];
        file->seek(0, SEEK_END);
    } else {
        auto* file               = simgrid::s4u::File::open(filename, nullptr);
        opened_files[filename] = file;
    }
}

static void action_io_close(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Closing");
    std::string filename     = args[2];
    auto* file               = opened_files[filename];
    file->close();
    // opened_files.erase(filename);
    // sg_file_close(file);
}

static void action_io_seek(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Seeking");
    std::string filename     = args[2];
    long long offset = std::atof(args[3].c_str());
    auto* file               = opened_files[filename];
    file->seek(offset, SEEK_SET);
}

static void action_io_delete(const simgrid::xbt::ReplayAction& args)
{
    // XBT_INFO("Deleting");
    std::string filename     = args[2];
    auto* file               = opened_files[filename];
    opened_files.erase(filename);
    file->unlink();
    // file->close();
    free(file);
}

static void compute(simgrid::xbt::ReplayAction& args)
{
    double amount = std::stod(args[2]);
    // XBT_INFO("Executing %f", amount);
    simgrid::s4u::this_actor::execute(amount);
}



int main(int argc, char* argv[])
{
  const auto* properties = simgrid::s4u::Actor::self()->get_properties();

  const char* instance_id = properties->at("instance_id").c_str();
  const int rank          = static_cast<int>(xbt_str_parse_int(properties->at("rank").c_str(), "Cannot parse rank"));
  const char* shared_trace =
      simgrid::s4u::Actor::self()->get_property("tracefile"); // Cannot use properties because this can be nullptr
  const char* private_trace  = argv[1];
  double start_delay_flops   = 0;

  if (argc > 2) {
    start_delay_flops = xbt_str_parse_double(argv[2], "Cannot parse start_delay_flops");
  }

  /* Setup things and register default actions */
  smpi_replay_init(instance_id, rank, start_delay_flops);

  /* Connect your callback function to the "blah" event in the trace files */
  xbt_replay_action_register("io-write", action_io_write);
  xbt_replay_action_register("io-write_at", action_io_write_at);
  xbt_replay_action_register("io-read", action_io_read);
  xbt_replay_action_register("io-read_at", action_io_read_at);
  xbt_replay_action_register("io-open", action_io_open);
  xbt_replay_action_register("io-close", action_io_close);
  xbt_replay_action_register("io-seek", action_io_seek);
  xbt_replay_action_register("io-delete", action_io_delete);
  // xbt_replay_action_register("compute", compute);

  /* The regular run of the replayer */
  if (shared_trace != nullptr)
    xbt_replay_set_tracefile(shared_trace);
  smpi_replay_main(rank, private_trace);
  return 0;
}

