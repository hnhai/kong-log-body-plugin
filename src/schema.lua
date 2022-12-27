return {
    name = "log-body",
    fields = {
        { config = {
            type = "record",
            fields = {
                { enable = { type = "boolean", default = true, }, },
                { user_id_field = { type = "string", }, },
            }, }, },
    },
}