use Mix.Config

config :quantum,
  cron: [
    "0 10,13,16,19,22 * * *": {Vim.Version, :check_latest},
    "30 7,12,18,20 * * *":    {Bot.Panpan.Memo, :reminder},
    "28 16 * * Sat": fn -> Bot.Panpan.reminder("青空レストランはじまるよ") end,
    "58 18 * * Sun": fn -> Bot.Panpan.reminder("鉄腕DASHはじまるよ") end
  ],
  timezone: :local

config :Stamp,
  base_url: "https://dl.dropboxusercontent.com/u/14918307/slack_stamp/",
  ohuro:    ["ohuro.jpg", "ohuro2.jpg", "ohuro3.jpg"],
  buwa:     ["buwa.jpg", "buwa2.jpg", "buwa3.jpg"],
  mu:       ["mu.jpg"],
  ira:      ["ira.jpg"],
  oyasumi:  ["oyasumi.jpg", "oyasumi2.jpg", "oyasumi3.jpg"],
  samui:    ["samui.jpg"],
  nandatte: ["nandatte.jpg"],
  dot:      ["dot.jpg", "dot2.jpg"],
  toberu:   ["toberu.jpg"],
  term:     [""]

config :Slack,
  bots:        ~w{ Panpan },
  panpan_icon: "https://dl.dropboxusercontent.com/u/14918307/slack_icon/panpan.jpg",
  paiman_icon: "https://dl.dropboxusercontent.com/u/14918307/slack_icon/paiman.png",
  vim_icon:    "https://dl.dropboxusercontent.com/u/14918307/slack_icon/vimgirl.jpg",
  kuma_icon:   "https://dl.dropboxusercontent.com/u/14918307/slack_icon/kuma.png"

config :Family,
  test: "test config"
