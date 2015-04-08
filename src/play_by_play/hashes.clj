(ns play-by-play.hashes
  (:require [play-by-play.strings :as strings]))

(defn to-camel-case-keys [k]
  (strings/to-camel-case (name k)))
