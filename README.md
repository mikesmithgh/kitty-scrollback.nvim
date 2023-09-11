<img src="https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a7357844-e0e4-4053-8c77-6d129528504f" alt="kitty-scrollback" style="width: 20%" align="right" />

# 😽 kitty-scrollback.nvim
Open your Kitty scrollback buffer with Neovim. Ameowzing!

[![neovim: v0.10+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10%2b&logo=neovim&labelColor=282828&logoColor=8faa80&color=414b32)](https://neovim.io/)
[![kitty: v0.29+](https://img.shields.io/badge/v0.29%2B-282828?style=flat-square&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAeMUlEQVR42uzBgQAAAAACoNFHX2GAKg8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICOvXOAlh0JwnCvbXNSvbbt7epZ27atSfXatm3btm0drW17d7br3Gcjk3Te%2Fb9zvmsE%2FySNpLLeHKML23WEs5MD073B03PC9Fr0xeij0WvF0Ynisx1by9PCu6004xjYakBWzLLAdm1hu5c4e2pXTuzNwdP9wnR99LzcZ3uIswsZkCbB2VWF6fNoeyj8K%2Fpi8Pbc4GgbWWGGGc0IDdjf0RTiG2sJ05F6kojvvxmqzPjszZztkgaktFMbywnTP9F2Ab6rrQT9m4cuu%2ByoptaAQw81I7e8XVA4O0SYno%2F%2BW0BG%2FsZBICF6NPPbRZszfa%2FNweBo3Tp0F4KbZpIWZ4vmTJtHDxRPpwlnV3d1f%2Bxb8f0H0e96%2BM8A1vU78fRxfP9O9PEezd8zxNFBge1W%2BfIzLL7PsjNPahJn%2BwUWGC14Wj3n7GJh%2BqIz2bAvGVA92mzXHdJpA9O3oi%2BG5gwLmIrRlkm%2BAs0jnrbV%2Fmn0md5N2VL8LvqsOLpAl0GXJYXWki5HzvYUYfqyjO1wYLNBBlSLeFpPd0bJvq4DRmGlGScr64yWN2npwHSEMD0R%2FTXaTsxfRZfN0%2BHB0VK6zKYEdB%2FoAF3O9ErZ6xxctqYB1RJctnuFof9N2J7TicHDlp9uamHaNXpn9Odou2b%2BLI5uz9nutN%2By2ZSmYPbzdiYdvBWm36tax9zTLgZU3gLYJ4Gw%2Fxu9I7jGYsPbh9f%2Bu%2F6t6N8lLn8Z2%2BdJPVMP78FAu2DCdPnAB33LU08%2BBlSLOLtzYmF%2FtOXImyFkvfXMKDpgpWf6FEJdgn9Hb82Xb6ykI%2FRmCAnertyj%2B9NORc2eAdWSM62faNDv2b85w5wDnbpcoTGVsD20x6h7u5v6QfSAfZszTD7Q7eSzeXOmB1Ncfs2eAdWiV%2FQl3vS9XJu9fV511jU9R7%2F1%2Bjn4R%2FRyHUvpZwzkvJRbRaGZLWJA9XPfNQj4T3q215APsm8P%2F9K5%2Bx6zHb%2Bkvrw9ZoFA1Yij90vd%2BRB6%2BtiANBCm6xFKWLJ3GpAGOr2EQMJS9VluQBoEN%2F3sCCUsU73s2IB0ELafIJiwJD%2BLkRvJgKQOAOcgmLAUnb3EgOQOAIxwwjLMXbahAWmht6OWcEsshH8nWhMB6BV2CCjE9F83pcWN2RDQTgq1OpQB6SJMTyOosFNVoVBJOnG0dl2HAgDhGQakzV6LTTuWFrhEWGHhaj1IkD7CdBYCCwv2dVMPwH7LzzgDbruFRapdS1Mr0Aq4HMGFxWg%2F0cfOmfoAtGpsIdVkIPS0j6kfIHh7DQI8nMIfcrYTmJqC24SH41lwEAZHR5n6AoTpRgR5GIW%2F9yjoWnPw7MA%2FEOahF9pjTf0BuiMR5qEUfoW%2B%2Fwhzq%2FAc46JiEMRTf7oxOduNEewhFL5bwtONywYI06MI9%2BCEwdlVTbGA%2F9m7CuA2mqU5YY51J0OYSToZwszMzMzMzMzMzMzMzDHb4VjO%2F7%2F3MTPTvm3XBW3ZutUJvipNVdcltgWj7Z7bnZ1ZFfelbCV8qVigD5U2%2B1Bts4Gam2Vqa5KokVmiqvz%2FJUsYqEBpIqdFXpzkim%2Bf8ZLcC1vA9xCSkwzcBsfBdXAe3IcGoAVoAtqARqCVf7vYc3GnelokWqUY6JIi0QcczE78qcgUx69n%2BGOXWgzU1SJTXh0TgjO8RPfCBn7BrhHpYJy%2F%2BTh%2FuyVwWKKz%2FP9WcFuDDj6AdswyreTXHtAUebIpfpRVkWgQRzQHcwJeKjJt59dORWTKToKGtR0f6AhPIt60ZoFs%2FejO7OiaOezqkZ3szvljLPT6hYTr1aM72dG1c9mGsV3ZjObBHi%2BiyQ2Ls1WDW7KDy6awSwe2sNtnjyT4cvfiSXb9xD52YuMitnVKPza7bVkPnPoXGEeCBk6aJerMObqDc%2FT%2FnKSBaGgMWiNPtQIFKKNJIovFQK0UA03lOKJIFM%2Fxj44fxK%2BKTEcxfSqdizILHh32o1vJVrcQWzuiPbt2fA%2BzxsWxly9fpoh4qxUiQrDA4z1KPEt61WPn96xjz588tssX4N7l02zHjMFscoNinuDDAxwsSxoM3LPI1J5z8Rg4qSO%2F%2F%2Bawcu0c5pjCtdQSmoK2%2FtU5gEADVTdLNJE7d4rjC50%2BrO8VmZYH%2BVBBbV8nVrCLu8i2YkBTFnb9AkQgjLCbl9jKQS3cLpx5HSuz68f3OuTLw4hQzArcGdR%2BQAs52WkWHyqcMDWX6AddOCzT5%2Fx6kmOCyUDVXHSHd79xx81mAw2F8zp8mH9hVsCvlT21ZRh3ulNblrL4%2BHgQ32Hgec5sX4Fpt1tmMLvnjmRxz5%2Fp4gtw8%2FQhNrNVKXec89%2FfznV9FfVu%2F7ejNy1wHty3GMlEXiOqQZQWMwTFQMuw3nfwAz5vkSjIjgCw2lUkm9EimN2%2FcgZE1xtYY7tUOJPqF2EX921yii%2BPosLY4p51XV300zlZ4RsomHPqgoOcjEdCEBwH18lryVugRIGKTDPxwYmuo5CQwQ6Cu08Qhvgj71wDwZ2GqPu32KzWpV0hfuQtnOrLs8cP2dLe9V0YBAosoyTMZKD8nEe7HLjjWzn%2FZmD9Tl4TN5NMFRSJVnN8LTAIPysyjWpLlCaJbxL62dnkmtKoBHtw9RyI7XSE3bjIpjY2O9WfC3s3uMSXJ7FRbG6HSq4KAjfoLQNXLBKN5dz5RYBvX2P722yk8uQ1fa0IUQZk%2Fi0Guqx1V4EPyn3kHN4qDQ50BbnO7lgFQrsMF%2Fasd5ovO2cNdaUvWNq4aofghxkzKDVx4%2FxSFAOFCiTyIjj6iexKeU3AsMZX91x%2F1zBQvyGyE1Eqvufb3dnEWjOsDYjscqwb2UF3X%2Ba0K8%2BeP33scl8OLZ%2FmklnAuJoFiyMLD45o4NPvFpm2YblK7jGvBRsptyLRQo7vNMwGjg%2Bvlm%2B%2BU9fK9YqwyLvX3RIAoh%2FcwVpdV38uH9zqFl%2BwyzC7bTmnin90zfysdEDa%2BxqED64t8LDqPG%2BvgSLReI5v7RnE0v5pvh9cObfTSLV5Yi8Q2G3YNnWAbr4s6FKdxcdb3eULtk6dNk5DquRh5XOms1f4P0L4gT4kkdeSqYGWqb5ioBH8Opv%2Ffw3HXo5zHHewfgewZ2%2BR6BD%2F2U7%2B71kcfTkacJgdWUcp2Uk2SzSXP%2B9PKQ1okDEV61U2wCnEunvhhCDhrSzy4Rh2J7wCv07g%2FxeqGUDiUTdfTm5eLPQeXsTdZvcjm7G74dXZ0%2BdHhQMAqgunNDLpPkY9ygSAA3YJH1x2RPjgNLitchxcnwXuQwPQwitdQCOqVvZCO3hd%2FvPh0JS6o%2BU5VloiH5T8csGtVxMn3%2BtYCvmUYxd%2F%2FmEo7tEaFDA944%2FbyPFXCskb1jnET%2Ff1smixT%2FTDmezGg%2FyvEf1onrBw5neuqkPBT2H2OCZS4PVfsLsR1V77cTO0BA8Id4V92TShp65j1KWUH7PIqVLkoXqTyqdV7OAshMu1sVvl8t96Vb5yPOBYhxJhwb4YcQvypeIWiSYrEt3W2N3kKH5TZw6jAo1Uguw0kw%2BVskh0M9mcgEysQ5BRN3JtnzFIiOTW%2BFgI5Z0AcCtU4cFELPm2e84Ih31BUY7Ia8c%2BXvWOH0BErNjnApzbtVa38WkfZLSHbzfQtkt2Gir6zDKNBkfBVRfq4k%2Fwm2MSWonJGaYQpU9oepDomnBTj%2F74P0WmFXYOUiq0VPLHfJncc7YNlPXZ%2Btu5Wqwm%2FslqCCURHj3ZKPR8qNZz1Jdds4cJvfb9yCaJ%2FLgZauLBTKx0OOLONV3Gpo1FTrku30DdwBlKwdC%2Fr%2FYE%2FL9HaALalOkqtsqhWXLUimUj34T1tIE%2Bwwt4MGK54yMt%2FhRAyViJbGQ0G2ir7SCmy3IAra9i%2B97R3ZMMAOEx%2FYT30R315dTmJQIzmcf8fRdK0pcnz46JzY7iXrCJ9Qo75Eunkr7JiodjE3JIKbS950i400v0yKM1Ac3KNBucF%2Brtx4NtNOj8wvEBx1MUP%2FDrPUx73gaWB%2BrvYtW%2F%2FdFFjv9hluggpv2UjFlkqlvSL%2FXPtnICPUo7lBhEWa4Qye%2BGV0lKNPznNQS77B64Zfvv2fNTSfoBxDyaL7wMmNEiRNiPnmUCbK75ywSkxcxgZQodgGWQD3DhsvdHVTsxqpZuv68ztbgtAlrE39qoXPwBCUe7OwwxpUYk5FiNuyqOK1KMVA510UEBlMWRZQTu0GpjRVOOIRyLIFg1UPyucwS8ZDJSHbJho2rk3dKgSFabuwP9K%2BYSJtujyFAhgt8KNSclGv7zEkK7AU8fxTgcAETq%2Fh8%2F22kzAETEDhcOAKKlwf0q5GSBNsTfsGg2NobXAaA93MbNoh6m1XrnsyBsjgMcC1UtNEVxGzTiyLF40Ci0qmq2BTQMLXNs5JoI8ehuQCQYFZlaq1skFzi%2B1aHXOhznrSVqBKpbYDzI0b20PwvxS51EnUBaNqpGPiHCxYTeEcmac4EUsCkcTKsFOuscDgBXDm0XyGWstOlHWHR34QAg0uw0qno%2B1HwkGl%2BM%2BdszvfG1CldKJHyJonQQ%2Bzcc59HYhh0zJOq83YD2W6qEoGCg7mrZ7wcODMQpPNebLw4t2OzV4A%2BvlpdVzZsx0WNq5M%2FEe8W1i%2BbBtfPaK96s4RCITVitkdoTZ7evuaWXIfrRbJt%2BPIhqJ3z2gcZzDzB2GMNE41o5dwY2rGred%2F52ZP088qtsvnqGHxPEBzi6DolElW%2BpSD%2FzGiIoH6ABikQnOH7WmiNA1hYFHfzo52LvHQrBmpXwSfSYNoqkWTQX928W2gJMPgDEaH1OnC%2FocADYt2i85teNebzQph%2BhUR3FthXD72t%2B760UKdF4Njf5YKzf%2F9tPkfxTp8p%2FaO02RWm5WaL%2BpuxUlFxnXkPBBXIUaMiwtcVnA58EGtO0SOo7A7uV9n%2BnOgyJowGVtOUD9i4cK0DyeBuZc6AAlghanxMHczoaAHDsmMASYIPNABAe00coAFw7tlvT%2B0YOR5HfjHmwMTXrXsbfxu6AH3JQn2rgzxcJu0kGavY%2F9q4CuHFkiSaL4cs5zHi7YfNIdjjOGkLHzMzMzMzMzMzMTAvHzMzM1H%2Ferco%2FdXa2MrHkyJKm6i0Epel%2BPdM93T2%2ByrRMHVDBGqjhRssmBDsm2V4M28Mvdu2riVGIbXiNgLd0VvTrfOVzsGponjzz6DOueKTBx6f0807cYliVLr%2Bvv%2FqyYBDwqgkNwOIX9pnSu1x2xK4CHX7qyF8xJyo%2Fb%2BlsyDTm6xD8G1ohd7Kk%2F0U5BRhVgnR6HNaIRCJzB932Lv8K1UfLdSUvemsK%2F3FX5pOzPJf4qh832LeZVBqjHDAMPdX%2FjwusKZgpOJVKwCcWRuKSBvn0wlvmZ55AGq8qyTNo7y2Uu%2F%2F6gxMagBdfOXMK%2Fv%2BbQhWBa3TYonLr5TKMZ%2BQ3YaVxg4NtXEegK9AZ6I5UV%2FKCf171UUGvww%2Fdshim8sCxBffJ63H8iMwq5FDj%2BA7dUXFkiG6%2F8NmXFUwZluXmsCwfFJakRRx%2FcNBEGHTaqWt%2BLbm5kNtifMP%2F1IgP1FKwMSe6hdypt1pT3xlFQHFXzRf3nZbtvwL0%2BRd2Zx55uj3uu7z%2BhniOxEO3XDXpZ4WM7IVLT3UG67Np90Bt3GzANptCeA5XRR50AroBHVkW%2FohI0sIwYwcGfb6mZQWvobPQXRy9QZeh09Bt6Lii6%2FVwYU1VrouKJqXy73qOhYJ%2B%2Bz8cHyLvGT4%2F%2BqX7G8r2CzHPAxDOVLDA5SCptphalTPiBXXZtNtA7GqxUkt%2B9Mx40q3AhpvplReWiJ3bv3ZTXNK8%2Bvodoj31cNmIqsUzT957q8gzcF9%2Fq9iEpoX9%2BJwohNqfQ0aQ1cqt%2BTGfg2wD9VlR4nurbBRwRUkvjKDXs8g3r%2FJg6CIi%2F0rNyUeC6fJf4Kha4cTBOH4EVwzT9hv10yB7tCpPBWAr391UDyGoggF7G9mLM6L%2B%2Fg7dlTHKs7a9kDps6TgynHwe%2FWE7Cq%2BcTywMjScN%2Fi%2BcBHTZkbupXjp7%2FGZhbMUF3IC7Y%2FIakB%2Bg5eqPoz3IaG1HYczntu%2BqJFmp%2B7eXZFLA3qaW%2FkAXoZOqFvgonDky5dqGO%2FLT8pHZxK3iM1qkSDq48AZdDky8qggxL3mql1aJuYpmxg0a4YRgpClPpJRWuC8AVvuHn54fLaF99fV78HGh23aUnHm1gcYcYp2KX9hjXBwDpwlvCO9kRLL%2FRubn0XrO2FqOrf0V5FT8fS%2BXMWSttv5gNwnd1ELnlVL7bVB%2Br%2Bu7AdECWaA1lzBcZTkU9Lgx4dqAMWK1RUsNTeGMuOnAm7LSaFBpMsAdeC8tWSgcRHv%2BpWO4v%2FywYCfdJXTYmrKmF5sgyUk0LRilwW%2B99Zpw4s85e2402WeDTBDYi%2Fk4jnCdSqYnqymCjDXTH%2Bimk%2BuohvUB33JjcICSkq%2BfgZxj%2BOccpBXsxXNpgUJ%2BreGpyIsG%2FjaXyhKvqd8kyLvavKhp2yw07Dxh8yHNm2fiApIlTz2qeRuwq47bO%2BFn3YyVQoZLT3sq8wTIn5gRsJdkaF0o9AHyX6ad%2BEiCUAqHSEu02WZQwNGeFPIDw5KHAvX%2FBpNQRKKGEcDlmQKddYSLfnDfYLJ66CMnH3cQaPIuWPmvOenAhJ8RMutQgrsDDbk0LHuTpj%2FQ1TbF8GgIBDLPmrYLQ9ErAOWIItF7JUf6AO4qbIIsqnZbmg%2FpkzgyAf5bJIH%2F4%2BNBj%2BsYTGwysWFPO20ul1FX5VwUjqB5ZMJKefiaPn492O2q984%2FYm3FT04i9h9ppXtU7hT86ovP01m7rZ%2Fws23LZQWZQXaoBNygu42SrT9Br%2FuIeDqNJCJ8HKnH0H3OBT%2B4oHDigHGnCR9O8jThcdT8J538%2FBe%2FHC96ieAfLBPHVrjRR9RfOSgtbQbO9SOMDYQYW4dP5jYcPydbgMMSo816WmjL3iZa21NNPbX5OGNW5WqtK4%2FdO%2BEe%2B8jOw1n%2FPqEV1Ce4YPfjF5Ty50Rw37UXIV6S8PNARiD%2BGs5y2prLDjKELJOtP4rObhOW5VUiktQy1bgaFknOpa2Vct5nJuhH8FLSjAC2HONuTvkNtdII%2FqHkNoHgRDqfrCGOSzk%2B5yA9IiJ5ac1OB23R20x7DNYn5kuv7KTrTz9c2C1AoO%2FGM4%2BMlsbqAejYi1RdNEIR7fKDgqUTNo%2Bo8hw79zfQKqyJxnweHeqO9EZIkg4O%2Bv3FiSbOIalICbg%2FMK6PxlNJcQewTeE4Fx1J1bjHPMTYcJixxZikVMKo7KWNu1thCBLeEZy24xp041lH4cgwxiDgjjy0GLvp7GPo9J3WFF%2Fxk3xlOAKR8OFx1Tcq%2BMbnDqC9N2IHuL7s%2FP23pANXtKtD%2FIFGWrvTTpHU0J2fOI4ZdLuXU%2Bv0DVwEJzn2T0qNvioNQPr6MvhEnMxBqYwVfW7aYUD1%2B%2Bu0veQz%2BTsEGAf17%2FXn2KSnjYYkloq682mEsZXU56b%2BB8ifwyfgSQ4yAiKyRFv3NSWRVBZ2CTTSyn536uuPLJ%2BAuJd5ynZbW%2BfwF7%2BLg4wEGIFt%2Bi0jkAzs0D%2BPRmSvYXQnJEk3jrrd5igM4i98JAcZEThr3j1Qr1vi4MaiE7ccJhy1IXp%2F0cHbAbh1B%2FEF9A%2FgwUVPdLuuR8DdUqL6RsNNht8JDDE2L8zYb3hho2K9rg5dEeakrcfQ2FOoMvH1V16mx%2B68gS4%2Fajc6YLRNN%2B8C4zrq85KB9edQo6%2F%2Bl3CQkRHh2C3QoAvCYJVP9FZfdDg%2BcEwfRm0dblwNrj%2F%2FcHQZkvzwcfjL%2FcBBBgfyBHRBmPuvv1iVDL3z9tl0%2BoN%2BAw0UVrb%2BBsdjRl39hzjIDNigx0F7h5umHQduuQYdfvjhCWO%2FNXum%2FV0277eTWfRHyRw01ghJ0rZmEWBbXR3xV1YRFppqakxjAEKMbWc8A8DYUWYRYFN1tcoEsDC%2FuhpzaxYcYxmAFEZFYaHKBLCAOTWRATjCeDEAxnY3iwAz585VmQAWsjIyzOMCSNKuxtsB%2BHxhMwhPbmnRiAQWfK2tpjAAQUlakGa0sZLDkc9f7nejC6%2BsoEAjAlgoN4EbgEQ5VAoa9SjwJmv1nyospJtjF3C9cTMBGfMZVXABt9vy%2FZMUCwh4PIY1AEOyLBk7HZixy4wmNCjkcjk5FkGThHw%2B14MejxGDfxenGX0osYDXjCK0zvZ2ys7IsIiZZGRnZlJXR4eRyP%2BK4vsbf4RluZa%2F9DupvuWvLy%2BnGenpFiGnCZh7yACySPHA31uc%2FNVpZhpojsgNwX0plqJJ3uZmqiouplkzZ1ok1AcgC8gEsoGMUi3v%2Fx5eKFeYZtKRzidgEz4R7%2BmR7H1OJ3mbmmheVRWV2Gw0Z%2FZsi3A6B2RUarNBZjAIkKFejcK7YVneSKCPn8HbhDG2ckiSruIG4bMJJux3jqfRWhlfp7ZA7I2NZMvNpdysLMqYM4fSDbO1twBZQqaQrS0vD7JWndCK7h7CSf3MMvJdPuW4kn%2Ftim63e3aaNSZ2D4KS5A7J8mBEljvDHs%2F88RO2us%2BXySfyWdWuB3e5aPasWRZZzAHIGjJX0wA8jS7X4xe0oM%2FXhOYe0GEOF3TaYraKI8BYAe4TUMFy%2F7F8bq5FDHMBOwHI%2F08VfPiFw11dy1uMnIYx1tmZy4VwbSKXNMitrRtahDAn%2FO3tG%2BMKr0S2%2FWhxbzFx%2BlOM1%2BL4UFCAi4Z8vnb%2B7VUWGUyLqhBjdk7kJYK680FIltewmKezQCKiqhz3LWNr9yc%2BH5Gk1aItmC0DYGZU%2Fas7q68%2BE4Tm%2BvEAx18T6Q7HvRHGNoCuWYzT8Qh2dGSj7oBjbU72Lbjg1gsx1h2baWUZAMsAxGaqDnm9PdAZ6I6iQzJ0ymKWMcf%2F2LsDj%2FbWOI7jyDLEwIRKJCDQKSQphCRKoCBoCRUIBPobElA1AwJJAokoxEJIUdUf81zPZbjcqEHn2Xm9%2BQKQ%2BLx%2BP%2BvUAQAABAAHAAHAAUAAcAAQABwABAAHAAHAAUAAcADQtwGgWq2GxcXFsLq6GrIsK8qvFgNAANje3g5vb2%2F%2Feb32xcVFGBgYMDgAqJMBqNVq375j%2F%2BHhIQwODhodANSJAJTL5fD8%2FBzHDgEAqGgAjI%2BPt4YOAQCoaABMTEzEgUMAACoiAJVKJby%2Fv0MAAEXNh4D7%2B%2Ftx3BAAQBEDQHd3d2g0GhAAQFHzHECpVAonJye%2FQqDZbIbh4WGDBEDqAaCFwPHxMQQA0IEBAAIAEAAgAAABAAIAEAAgAAABAAIAEAAgAAABAAIAEAAgAAABAAIAEAAgAAABAAIAEADaReDx8RECAFDaAEAAAAIABAAgALQQODo6KgoCABAAIAAAAQACABAAIAAAAQACABAAWn9tuF6v%2FwqB%2B%2Fv7%2BK4CI28fAAEgbQR2d3c7YaQAEABaCJyenv4YgMvLy04ZKgAEgHjLy8s%2FBuDm5qZThgoAAWBhYSF8fn7%2BGIDDw0Mjbx8AASDd8X99fYUsy4y8fQAEgDTHH69Wqxk4AJQ6APPz878e%2F9bWlnG3D4AAYPwAEACMHwACgPEDQAAwfgAIAMYPAAHA%2BAEgABg%2FAJR2A8YPAAHA%2BAEgABg%2FAAQA4weAAGD8ABAAjB8AAoDxA0AAMH4ACADGDwABwPgBIAAYPwAEgDb%2Fht%2Fm5mYu3jtQqVRyfV1dXXkCQABIf%2Fxzc3Ph6uoqfi25v%2Fi9PTs7C1mW5QsAAWB6ejq58a%2Bvr8evI7n7%2BPgIs7Oz%2BQBAAIj%2FNb27u0tq%2FP39%2FXFISQLQegtyuVz%2BewAEgJGRkfbH71%2F%2Ftm9mZubvARAApqamkhp%2FvL29veQBWFlZ%2BXsABIC%2Bvr6kxh9vbW0teQAmJycBoHx8CNhoNJIZf7xqtRpeX1%2BTHX%2F8zKVUKuUDAAGgt7c33N7e%2Fu%2BLOjc2NnL5MMzS0lLrJxdJ3cvLSxgbG%2FNTAOXrOYCenp6ws7MTzs%2FPw%2FX1dTg4OAijo6O5fiIuDqler4enp6fcD7%2FZbP77PR0aGirOcwDyenDnUWABwAFAAHAAEAAcAAQABwABwAFAAHAAEAAcAAQABwABwAFAAHAAEAAcAAQABwABAAACgAOAAOAAIAA4AAgADgACgAOAAOAAIAA4AAgADgACgAOAAOAA8E%2B7dXBDQBRFYVhMDcaCPmhGNEQvYj9sRQGzE9pg5WSWJJaSee%2F7kr%2BDe5I7UsyrHYBa50%2BTXsZQXc80nQScqxuAujSAbXUD0CbBoElXo6imy%2Bf7D8v0MI7iu6dFgi9tOhpJsR3SLP0E67RPp9Sn2yhTn7q0S6v0NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG8UXmE3s3VNpQAAAABJRU5ErkJggg%3D%3D&label=kitty&labelColor=1a1c1e)](https://sw.kovidgoyal.net/kitty/)

> [!WARNING]  
> This project is still a work in progress and not considered stable

https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/5aba1ba2-1883-4ac0-bad3-7ecd12f46a7e

## ✨ Features
- 😻 Navigate Kitty's scrollback buffer with Neovim
- 🐱 Copy contents from Neovim to system clipboard
- 😺 Send contents from Neovim to Kitty shell
- 🙀 Execute shell command from Neovim to Kitty shell

## 🏃 Quickstart

To quickly test this plugin without changing your configuration run the command:
```sh
sh -c "$(curl -s https://raw.githubusercontent.com/mikesmithgh/kitty-scrollback.nvim/main/scripts/mini.sh)"
```
> [!NOTE]  
> It is good practice to first
> [read the script](https://github.com/mikesmithgh/kitty-scrollback.nvim/blob/main/scripts/mini.sh)
> before running `sh -c` directly from the web

## 📦 Installation

### Prerequisites
- Neovim [v0.10+](https://github.com/neovim/neovim/releases)
- Kitty [v0.29+](https://github.com/kovidgoyal/kitty/releases)

<details>

<summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    config = function()
      require('kitty-scrollback').setup()
    end,
  }
```

</details>
<details>

<summary>Using Neovim's built-in package support <a href="https://neovim.io/doc/user/usr_05.html#05.4">pack</a></summary>

```bash
mkdir -p "$HOME/.local/share/nvim/site/pack/mikesmithgh/start/"
cd $HOME/.local/share/nvim/site/pack/mikesmithgh/start
git clone git@github.com:mikesmithgh/kitty-scrollback.nvim.git
nvim -u NONE -c "helptags kitty-scrollback.nvim/doc" -c q
mkdir -p "$HOME/.config/nvim"
echo "require('kitty-scrollback').setup()" >> "$HOME/.config/nvim/init.lua"
```

</details>

## ✍️ Configuration

### Kitty 
The following steps outline how to properly configure [kitty.conf](https://sw.kovidgoyal.net/kitty/conf/)

<details>
<summary>Enable <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control">allow_remote_control</a></summary>

  - Valid values are `yes`, `socket`, `socket-only`
  - If `kitty-scrollback.nvim` is the only application controlling Kitty then `socket-only` is preferred to continue denying TTY requests.

</details>
<details>
<summary>Set <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on">listen_on</a> to a unix socket</summary>

  - For example, `listen_on unix:/tmp/kitty`

</details>
<details>
<summary>Enable <a href="https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration">shell_integration</a></summary>

  - Set `shell_integration` to `enabled`
  - Do not add the option `no-prompt-mark`

</details>
<details>
<summary>Add <code>kitty-scrollback.nvim</code> mappings</summary>

  - Generate default Kitten mappings and add to `kitty.conf`
  ```sh
  nvim --headless +'KittyScrollbackGenerateKittens' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1
  ```

</details>

<details>
<summary>Completely close and reopen Kitty</summary>
</details>

</details>
<details>
<summary>Check the health of <code>kitty-scrollback.nvim</code></summary>

  ```sh
  nvim +'KittyScrollbackCheckHealth' +'quit!'
  ```
  - Follow the instructions of any `ERROR` or `WARNINGS` reported during the healthcheck

</details>
<details>
<summary>Test <code>kitty-scrollback.nvim</code> is working as expected by pressing <code>ctrl+shift+h</code> to open the scrollback buffer in Neovim</summary>
</details>

<details>
<summary>See example <code>kitty.conf</code> for reference</summary>

  ```sh
  allow_remote_control yes
  listen_on unix:/tmp/kitty
  shell_integration enabled
  
  # kitty-scrollback.nvim Kitten alias
  action_alias kitty_scrollback_nvim kitten /Users/mike/gitrepos/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py --cwd /Users/mike/gitrepos/kitty-scrollback.nvim/lua/kitty-scrollback/configs
   
  # Browse scrollback buffer in nvim
  map ctrl+shift+h kitty_scrollback_nvim
  # Browse output of the last shell command in nvim
  map ctrl+shift+g kitty_scrollback_nvim --config-file get_text_last_cmd_output.lua
  # Show clicked command output in nvim
  mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config-file get_text_last_visited_cmd_output.lua
  ```
  
</details>

### Kitten arguments

### Nerd Fonts 
By default, `kitty-scrollback.nvim` uses [Nerd Fonts](https://www.nerdfonts.com) in the status window. If you would like to 
use ASCII instead, set the option `status_window.style_simple` to `true`. 

<details>
  <summary>Status window with Nerd Fonts <code>opts.status_window.style_simple = false</code></summary>
  
  https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/4cf5b303-5061-43da-a857-c99daea82332
  
</details>
<details>
  <summary>Status window with ASCII text <code>opts.status_window.style_simple = true</code></summary>
  
  https://github.com/mikesmithgh/kitty-scrollback.nvim/assets/10135646/a0e1b574-59ab-4abf-93a1-f314c7cd47b3
  
</details>


## 🫡 Commands and Lua API
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`
| Command                              | API                              | Description                                                             |
| :----------------------------------- | :------------------------------- | :---------------------------------------------------------------------- |
| `:KittyScrollbackGenerateKittens[!]` | `generate_kittens(boolean\|nil)` | Generate Kitten commands used as reference for configuring `kitty.conf` |                 
| `:KittyScrollbackCheckHealth`        | `checkhealth()`                  | Run `:checkhealth kitty-scrollback` in the context of Kitty             |

## ⌨️ Keymaps and Lua API
The API is available via the `kitty-scrollback.api` module. e.g., `require('kitty-scrollback.api')`
| `<Plug>` Mapping            | Default Mapping | Mode  | API                   | Description                                                                             |
| --------------------------- | --------------- | ----- | --------------------- | --------------------------------------------------------------------------------------- |
| `<Plug>(KsbExecuteCmd)`     | `<C-CR>`        | n,i   | `execute_command()`   | Execute the contents of the paste window in Kitty                                       |
| `<Plug>(KsbPasteCmd)`       | `<S-CR>`        | n,i   | `paste_command()`     | Paste the contents of the paste window to Kitty without executing                       |
| `<Plug>(KsbToggleFooter)`   | `g?`            | n     | `toggle_footer()`     | Toggle the paste window footer that displays mappings                                   |
| `<Plug>(KsbCloseOrQuitAll)` | `<Esc>`         | n     | `close_or_quit_all()` | If the current buffer is the paste buffer, then close the window. Otherwise quit Neovim |
| `<Plug>(KsbQuitAll)`        | `<C-c>`         | n,i,t | `quit_all()`          | Quit Neovim                                                                             |
| `<Plug>(KsbVisualYankLine)` | `<Leader>Y`     | v     |                       | Maps to `"+Y`                                                                           |
| `<Plug>(KsbVisualYank)`     | `<Leader>y`     | v     |                       | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankEnd)`  | `<Leader>Y`     | n     |                       | Maps to `"+y$`                                                                          |
| `<Plug>(KsbNormalYank)`     | `<Leader>y`     | n     |                       | Maps to `"+y`                                                                           |
| `<Plug>(KsbNormalYankLine)` | `<Leader>yy`    | n     |                       | Maps to `"+yy`                                                                          |

## 🛣️ Roadmap
- [x] document setup with remote control and shell integration
- [x] add quick setup to allow user to test easily before installing
- [ ] add documentation and examples
- [ ] add details about relevant kitty config ( `scrollback_lines`, `scrollback_pager`, `scrollback_pager_history_size`, `scrollback_fill_enlarged_window`)
- [ ] release v1
- [ ] ci/cd
- [ ] add support for https://github.com/m00qek/baleia.nvim

## 👏 Recommendations
The following plugins are nice additions to your Neovim and Kitty setup.
- [vim-kitty](https://github.com/fladson/vim-kitty) - Syntax highlighting for Kitty terminal config files
- [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) - Seamless navigation between Neovim and Kitty split panes 

## 🤝 Ackowledgements
- Kitty [custom kitten](https://sw.kovidgoyal.net/kitty/kittens/custom/) documentation
- [baleia.nvim](https://github.com/m00qek/baleia.nvim) - very nice plugin to colorize Neovim buffer containing ANSI escape seqeunces. I plan to add integration with this plugin 🤝
- [kovidgoyal/kitty#719 Feature Request: Ability to select text with the keyboard (vim-like)](https://github.com/kovidgoyal/kitty/issues/719) - ideas for passing the scrollback buffer to Neovim
- [kovidgoyal/kitty#2426 'Failed to open controlling terminal' error when trying to remote control from vim](https://github.com/kovidgoyal/kitty/issues/2426) - workaround for issuing kitty remote commands without a tty `listen_on unix:/tmp/mykitty`
- [kovidgoyal/kitty#6485 Vi mode for kitty](https://github.com/kovidgoyal/kitty/discussions/6485) - inpiration to leverage Neovim's terminal for the scrollback buffer
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) - referenced for color darkening, thank you folke!
- [lazy.nvim](https://github.com/folke/lazy.nvim) - referenced for window sizing, thank you folke!
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - quickstart `mini.sh` and inspiration/reference for displaying keymapping footer
- [cellular-automaton.nvim](https://github.com/Eandrju/cellular-automaton.nvim) - included in a fun example config
- StackExchange [CamelCase2snake_case()](https://codegolf.stackexchange.com/a/177958/119424) - for converting Neovim highlight names to `SCREAMING_SNAKE_CASE`

- TODO doc up:
  - see :help clipboard
  - pbcopy and pbpaste on macos
  - xclip or wayland on linux
  - anything preceding `--nvim-args` will be passed to nvim, do no use --cmd or an error will occur
  - `--nvim-no-args` to disable default and pass no args
  - `--env` to set environment variables e.g., `--env NVIM_APPNAME=altnvim`
  - `--config-file` to set lua file with `config` function to set plugin options
