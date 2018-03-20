#!/usr/bin/env ruby

=begin

  CardFS storage
  by Michael Zinn 2018
  @RedNifre on Twitter
  

Store UTF-8 strings in decks of cards.

Currently, this supports storing in a standard 52 card deck or 32 card quartett deck.

Example usage:

./cardfs.rb encode --deck french52 "Hello"

  Puts "Hello" in the standard 52 card deck


./cardfs.rb enc "Hello"

  Same as above


./cardfs.rb decode -d quartett F3 A3 A2 H3 C2 A1 E2 D3 E4 D4 H2 B1 G4 B4 H1 G3 D2 F1 H4 C1 F4 C3 D1 C4 E1 F2 G1 A4 B2 B3 E3 G2

  Decodes a quartett deck (A1 to H4). Cards are not case sensitive.


./cardfs.rb dec Ac 4h 8s 2s Kh Th 5s 9c 3s Qc 6c 8h 7h 7c Jh 6s 9s 5c 5d 3d 2h Ks 4c 5h 3c Jd 7s 8c 6h Js Qh 2c Jc 4s 4d Kc Ts 3h Td Ad Tc 8d 6d 2d 9h Ah As Kd Qd 7d 9d Qs

  Decodes a standard deck. Cards are not case sensitive.


=end


### Deck Definitions ##########################################################

# poker (52 cards)
ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"] # ace, ten, jack, queen, king
suits = ["d", "h", "s", "c"] # diamonds, hearts, spades, clubs
$poker = suits.product(ranks).map { |p| p.reverse.join }

# skat (German game)
$skat = suits.product(["A", "7", "8", "9", "T", "J", "Q", "K"]).map { |p| p.reverse.join }

# quartett deck (32 cards)
sets = ("A".."H").to_a
numbers = (1..4).to_a
$quartett = sets.product(numbers).map { |p| p.join }

$decks = {
  "poker" => $poker,
  "skat" => $skat,
  "quartett" => $quartett,
  "tarot" => ["0",  "I", "II", "III",  "IV",   "V",  "VI", "VII", "VIII",
              "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII",
              "XVIII", "XIX", "XX", "XXI"]
}


### Utils #####################################################################

def factorial(n)
  Math::gamma(n+1)
end


### Math Stuff ################################################################

def encode_string_to_permutation(s, cards)
  i = encode_string_to_int(s)
  if(i > (factorial(cards.size) - 1))
    raise "String is too long for this card deck! Please make sure it is no longer than #{Math::log(factorial(cards.size),256).to_i} bytes (was #{Math::log(i, 256).ceil})."
  end
  encode_int_to_permutation(encode_string_to_int(s), cards)
end

def encode_string_to_int(s)
  s.unpack("C*").inject(0) { |a, b| a * 256 + b }
end

def encode_int_to_permutation(i, cards)
  if(cards.empty?)
    []
  else
    ci = i % cards.size
    c = cards[ci]
    [c] + encode_int_to_permutation( (i/cards.size).to_i, cards - [c]) 
  end
end

def decode_permutation_to_string(arrangement, reference_deck)
  decode_array_to_string(decode_int_to_array(decode_permutation_to_int(arrangement, reference_deck)))
end

def decode_array_to_string(ba)
  ba.pack("C*").force_encoding("utf-8")
end

def decode_int_to_array(i)
  if(i == 0) 
    []
  else
    decode_int_to_array((i / 256).to_i) + [i % 256] 
  end
end

def decode_permutation_to_int(permutation, deck) 
  decode_permutation_to_int_multiplied(permutation, deck, 1)
end

def decode_permutation_to_int_multiplied(permutation, deck, multiplier)
  if(permutation.empty?)
    0
  else
    c = permutation.first
    d = deck.index(c)
    d * multiplier + decode_permutation_to_int_multiplied(permutation - [c], deck - [c], multiplier * deck.size)
  end
end


### Command Line Interface ####################################################

hack = 1
command = ARGV[0]
deck = $poker
if ["--deck", "-d"].include?(ARGV[1])
  deckname = ARGV[2]
  if $decks.include? deckname
    deck = $decks[ARGV[2]]
    hack = 3
  else
    raise "Deck #{deckname} not found, pleases use one of #{$decks.keys}"
  end
end

case command
when "decode", "dec"
  puts "Decoding..."
  permutation = ARGV[hack..-1].map do |s|
    if(deck == $decks["tarot"]) 
      s.upcase
    else
      s.capitalize 
    end
  end
  puts decode_permutation_to_string(permutation, deck)
when "encode", "enc"
  text = ARGV[-1]
  puts "Encoded \"#{text}\":"
  puts encode_string_to_permutation(text, deck).join(" ")
else
  puts "First parameter must be encode or decode"
end
