module Data.OrderedMap (
    OrderedMap
  , fromList
  , toList
  , keys
  , (!)
  , Data.OrderedMap.lookup
  , size
  , empty
  , union
  , unions
  , intersectionWith
  , difference
  ) where

import qualified Data.Maybe as Maybe

data OrderedMap key value = OrderedMap { toList :: [(key, value)] }
  deriving (Show, Eq, Functor, Foldable, Traversable)

instance Eq key => Monoid (OrderedMap key value) where
  mempty = fromList []
  mappend = union

fromList :: [(key, value)] -> OrderedMap key value
fromList = OrderedMap

keys :: OrderedMap key value -> [key]
keys (OrderedMap pairs) = fst <$> pairs

infixl 9 !

(!) :: Eq key => OrderedMap key value -> key -> value
map ! key = Maybe.fromMaybe (error "no value found for key") $ Data.OrderedMap.lookup key map

lookup :: Eq key => key -> OrderedMap key value -> Maybe value
lookup key = Prelude.lookup key . toList

size :: OrderedMap key value -> Int
size = length . toList

empty :: OrderedMap key value
empty = OrderedMap []

union :: Eq key => OrderedMap key value -> OrderedMap key value -> OrderedMap key value
union a b = OrderedMap $ toList a ++ toList (difference b a)

unions :: Eq key => [OrderedMap key value] -> OrderedMap key value
unions = foldl union empty

intersectionWith :: Eq key => (a -> b -> c) -> OrderedMap key a -> OrderedMap key b -> OrderedMap key c
intersectionWith combine (OrderedMap a) (OrderedMap b) = OrderedMap $ a >>= (\ (key, value) -> maybe [] (pure . (,) key . combine value) $ Prelude.lookup key b)

difference :: Eq key => OrderedMap key a -> OrderedMap key b -> OrderedMap key a
difference (OrderedMap a) (OrderedMap b) = OrderedMap $ filter ((`notElem` extant) . fst) a
  where extant = fst <$> b
