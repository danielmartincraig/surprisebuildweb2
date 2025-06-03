(ns surprisebuild.surprisebuildweb2.subs
  (:require [re-frame.core :as rf]))

(rf/reg-sub :app/todos
            (fn [db _]
              (:todos db)))

(rf/reg-sub :app/app-state
            (fn [db _]
              (:app-state db)))

(rf/reg-sub :app/comparison
            :<- [:app/app-state]
            (fn [app-state _]
              (:comparison app-state)))

(rf/reg-sub :app/coordinates
            :<- [:app/app-state]
            (fn [app-state _]
              (:coordinates app-state)))

(rf/reg-sub :app/comparison-parts
            :<- [:app/comparison]
            (fn [comparison _]
              (:parts comparison)))

(rf/reg-sub :app/coordinate
            :<- [:app/coordinates]
            (fn [coordinates [_ i]]
              (get coordinates i)))

