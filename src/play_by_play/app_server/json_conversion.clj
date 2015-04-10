(ns play-by-play.app-server.json-conversion
  (:require [play-by-play.hashes :as hashes]
            [cheshire.core :as cheshire]))

(defn to-json [object]
  (cheshire/encode object {:key-fn hashes/to-camel-case-keys}))
