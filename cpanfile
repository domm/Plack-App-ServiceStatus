# This file is generated by Dist::Zilla::Plugin::CPANFile v6.017
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "Class::Accessor::Fast" => "0";
requires "JSON::MaybeXS" => "0";
requires "Log::Any" => "0";
requires "Module::Runtime" => "0";
requires "Plack::Response" => "0";
requires "Try::Tiny" => "0";
requires "base" => "0";
requires "perl" => "5.018";

on 'build' => sub {
  requires "Module::Build" => "0.28";
};

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::MockModule" => "0";
  requires "Test::MockObject" => "0";
  requires "Test::More" => "0";
};

on 'configure' => sub {
  requires "Module::Build" => "0.28";
};
