(ns surprisebuild.surprisebuildweb2.core
  (:require
   [reagent.core :as r]
   [reagent.dom :as d]
   [uix.core :as uix :refer [defui $]]
   [uix.dom]
   [uix.re-frame :as urf]
   [surprisebuild.surprisebuildweb2.hooks :as hooks]
   [surprisebuild.surprisebuildweb2.subs]
   [surprisebuild.surprisebuildweb2.handlers]
   [surprisebuild.surprisebuildweb2.fx]
   [surprisebuild.surprisebuildweb2.db]
   [surprisebuild.surprisebuildweb2.config :as config]
   [re-frame.core :as rf]
   [clojure.string :as str]
   [goog.string :as gs]
   [goog.string.format]
   [goog.object :as gobj]
   [react-oidc-context :as oidc :refer [AuthProvider useAuth]]
   [react :refer [StrictMode]]))

;; -------------------------
;; Views

(defn home-page []
  [:div [:h2 "Welcome to Reagent!"]])

(defui app []
  ($ :h1 "hi"))

;; -------------------------
;; Initialize app

(defonce root
  (uix.dom/create-root (js/document.getElementById "app")))

(defn render []
  (rf/dispatch-sync [:app/init-db surprisebuild.surprisebuildweb2.db/default-db])
  (uix.dom/render-root ($ app) root))

(defn ^:export init! []
  (render))
