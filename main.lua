SMODS.Atlas {
    key = "FortuneJokers",
    path = "jokers.png",
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = "FortuneDecks",
    path = "decks.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "gamblecore",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 0 },
    config = { extra = { odds = 5 } },
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.before then
            for index, value in ipairs(G.play.cards) do
                if value.config.center == G.P_CENTERS.c_base and not value.debuff then
                    if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds then
                        value:set_ability(
                            G.P_CENTERS[SMODS.poll_enhancement({ guaranteed = true, type_key = 'spinning!!' })], true,
                            false)
                        value:juice_up()
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = "responsible",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 0 },
    cost = 6,

    config = { extra = { chipsgained = '10', interestcol = '1', currentchips = '0' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chipsgained, card.ability.extra.interestcol, card.ability.extra.currentchips } }
    end,
}

SMODS.Joker {
    key = "stairs",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 0 },
    cost = 20,
}

SMODS.Joker {
    key = "jokercore",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 0 },
    cost = 6,
    config = { extra = { odds_c = 2, odds_u = 8, odds_r = 20 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds_c, card.ability.extra.odds_u, card.ability.extra.odds_r } }
    end,
    calculate = function(self, card, context)
        ---I know about context.main_eval, but if possible i want this to be backwards compatible with old calc
        if context.end_of_round and not context.game_over and not context.individual and not context.repetition and #G.jokers.cards <= (G.jokers.config.card_limit - 1) then
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_r then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 1, nil, nil, nil, 'rare')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_u then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 0.9, nil, nil, nil, 'uncommon')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
            if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds_c then
                G.GAME.joker_buffer = G.GAME.joker_buffer + 1
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'common')
                        card:add_to_deck()
                        G.jokers:emplace(card)
                        card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true
                    end
                }))
                card_eval_status_text(context.blueprint_card or self, 'extra', nil, nil, nil,
                    { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
        end
    end
}

SMODS.Joker {
    key = "Fishingcore",
    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 0 },
    cost = 6,
    config = { extra = { odds = 10 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal or 1, card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.before then
            for index, value in ipairs(G.play.cards) do
                if value.config.center == G.P_CENTERS.c_base and not value.debuff then
                    if pseudorandom('aw dangit') < G.GAME.probabilities.normal / card.ability.extra.odds and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = (function()
                                local s_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil,
                                    'wii play fishing')
                                s_card:add_to_deck()
                                G.consumeables:emplace(s_card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end)
                        }))
                        return {
                            message = localize('k_plus_spectral'),
                            colour = G.C.SECONDARY_SET.Spectral,
                            card = card
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker {
    key = "tungsten",


    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "pants",


    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 1 },
    cost = 6,
}
SMODS.Joker {
    key = "bpay",


    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "critical",
    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 1 },
    config = { extra = { mult = 4, odds = 10 } },
    cost = 8,
}

SMODS.Joker {
    key = "rockjumpscare",


    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 1 },
    cost = 6,
}

SMODS.Joker {
    key = "spanishbutton",


    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 0, y = 2 },
    cost = 6,
}

SMODS.Joker {
    key = "burgerman",

    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 1, y = 2 },
    cost = 6,
}

Trafficcolors = {
    ["RED"] = G.C.RED,
    ["BLUE"] = G.C.BLUE
}
SMODS.Joker {
    key = "trafficlight",
    rarity = 1,
    atlas = "FortuneJokers",
    pos = { x = 2, y = 2 },
    cost = 6,
    config = { extra = { blue = false, increase = 1, textvar = "Discard", colour = "RED", } },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.increase,
                card.ability.extra.textvar,
                colours = {
                    Trafficcolors[card.ability.extra.colour],
                },
            }
        }
    end,
    calculate = function(self, card, context)
        ---I know about context.main_eval, but if possible i want this to be backwards compatible with old calc
        if context.end_of_round and not context.game_over and not context.individual and not context.repetition and not context.blueprint then
            if card.ability.extra.blue == false then
                local obj = G.P_CENTERS.j_RAXD_trafficlight
                card.ability.extra.blue = true
                card.ability.extra.colour = "BLUE"
                card.ability.extra.textvar = "Hand"
                obj.pos.y = 3
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize('k_light_blue'), colour = G.C.BLUE })
            else
                local obj = G.P_CENTERS.j_RAXD_trafficlight
                card.ability.extra.blue = false
                card.ability.extra.colour = "RED"
                card.ability.extra.textvar = "Discard"
                obj.pos.y = 2
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize('k_light_red'), colour = G.C.RED })
            end
        end
        if context.setting_blind then
            if card.ability.extra.blue then
                ease_hands_played(card.ability.extra.increase)
            else
                ease_discard(card.ability.extra.increase)
            end
        end
    end
}

SMODS.Joker {
    key = "deathball",

    rarity = 3,
    atlas = "FortuneJokers",
    pos = { x = 3, y = 2 },
    cost = 6,
}

SMODS.Joker {
    key = "entity",

    rarity = 2,
    atlas = "FortuneJokers",
    pos = { x = 4, y = 2 },
    cost = 6,
}
