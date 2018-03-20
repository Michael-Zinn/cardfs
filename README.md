# CardFS

Encode UTF-8 texts in deck of cards as permutation.

Supported decks:

| Name | Description | Storage capacity |
|------|-------------|------------------|
| poker | 52 cards | 28 bytes |
| skat | 32 cards | 14 bytes |
| quartett | A1 to H4 | 14 bytes |
| tarot | 0 to XXI | 8 bytes |

## How to use

### Encode examples

```
ruby cardfs.rb encode --deck quartett "entropy"

chmod +x cardfs.rb
./cardfs.rb enc "defaults to poker deck"
```

### Decode examples

```
./cardfs.rb decode -d tarot XIV X I XVI VIII XIII III XIX XV V XXI VI IX XVIII XI XX VII 0 II IV XII XVII
./cardfs.rb dec Qc Td 9c 6s Tc 8s 8d Ac 9h 7s Jd 9s 4s Qd Th 4d Ks 6c As 8c 5d Ah 8h Qs 6d 9d 7c 2d Kc Ts Jc 7d 2c Jh 3h 3d 2h Ad Kd 4h 5h 6h 7h Qh Kh 2s 3s 5s Js 3c 4c 5c
```

### How does it work?

It converts a string to bytes to a large integer (little endian) to a deck permutations (also little endian) and back.
