UsePlugin 'ai-review.vim'

call ddu#custom#patch_global(#{
    \  kindOptions: {
    \    'ai-review-request': #{
    \      defaultAction: 'open',
    \    },
    \    'ai-review-log': #{
    \      defaultAction: 'resume',
    \    },
    \  },
    \})

call ai_review#config({ 'chat_gpt': { 'model': 'gpt-4o' } })
