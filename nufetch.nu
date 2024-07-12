let arts = [
  {
    name: "Windows",
    art: 
$"(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################

(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################
(ansi blue)################  ################"
  },
  {
    name: "Arch Linux",
    art:
$"(ansi blue)                   -`
(ansi blue)                  .o+`
(ansi blue)                 `ooo/
(ansi blue)                `+oooo:
(ansi blue)               `+oooooo:
(ansi blue)               -+oooooo+:
(ansi blue)             `/:-:++oooo+:
(ansi blue)            `/++++/+++++++:
(ansi blue)           `/++++++++++++++:
(ansi blue)          `/+++ooooooooooooo/`
(ansi blue)         ./ooosssso++osssssso+`
(ansi blue)        .oossssso-````/ossssss+`
(ansi blue)       -osssssso.      :ssssssso.
(ansi blue)      :osssssss/        osssso+++.
(ansi blue)     /ossssssss/        +ssssooo/-
(ansi blue)   `/ossssso+/:-        -:/+osssso+-
(ansi blue)  `+sso+:-`                 `.-/+oso:
(ansi blue) `++:.                           `-/+/
(ansi blue) .`                                 `"
  }
]

def get_art [--fake: string] {
  if ($fake | is-not-empty) {
    return ($arts | where name == $fake | first | get art)
  }

  let host = sys host
  let target = $arts | where name == $host.name | first 
  if ($target | is-empty) {
    return ""
  } else {
    let ar = $target | get art
    return $ar
  }
}

def get_pc_model [] {
    if ($nu.os-info.name == "windows") {
      let info = wmic computersystem get model /format:csv | from csv | first
      return $info.Model
    } else if ($nu.os-info.name == "linux") {
      return (cat /sys/class/dmi/id/product_name)
    }
}

def get_shell [] {
    let ppid = debug info | get ppid
    return (ps | where pid == $ppid | get name | split row "." | get 0)
}

def get_local_ip [] {
    let end = (ipconfig | parse --regex 'IPv4\sAddress(.+)192.168.0.(\d+)' | first | get capture1)
    return $"192.168.0.($end)"
}

def calculate_packages [] {
  # TODO
  return {
    choco: 123,
    scoop: 1337
  }
}

def main [ --fake: string ] {
  let art = get_art --fake $fake

  let hostinfo = sys host
  let pkgs = calculate_packages | transpose name count | each {|x| $"($x.name) - ($x.count)"} | str join ", "
  let cpus = sys cpu | get brand | uniq
  let disks = sys disks | each {$"(ansi yellow)Disk \(($in.mount)\)(ansi white): ($in.total) / ($in.free) \(((((($in.total - $in.free) / $in.total) * 100) | math floor))%\)"}

  let information = [
    $"(ansi blue)(whoami)(ansi white)@(ansi blue)($hostinfo.hostname)(ansi white)",
    "-------------------------------------",
    $"(ansi yellow)OS(ansi white): ($hostinfo.long_os_version) ($hostinfo.kernel_version)",
    $"(ansi yellow)Model(ansi white): (get_pc_model)",
    $"(ansi yellow)Kernel(ansi white): ($env.OS) ($hostinfo.kernel_version)",
    $"(ansi yellow)Uptime(ansi white): ($hostinfo.uptime)",
    $"(ansi yellow)Shell(ansi white): (get_shell)",
    $"(ansi yellow)Packages(ansi white): ($pkgs)",
    $"(ansi yellow)CPUs(ansi white): ($cpus | str join ', ')",
    $"(ansi yellow)Mem(ansi white): ((sys mem | $'($in.total) / (ansi red)($in.used)(ansi white) / (ansi green)($in.free)(ansi white)'))",
    ...$disks,
    $"(ansi yellow)Local IP(ansi white): (get_local_ip)",
  ]

  
  print ([[art, information]; [$art ($information | str join "\n")]] | table -i false)
}