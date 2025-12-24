local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets({ 'typescriptreact', 'typescript', 'astro' }, {
  -- Snippet 1: Import Form components
  s('formimport', {
    t 'import { FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form";',
  }),

  -- Snippet 2: FormField boilerplate with FormControl
  s('formfield', {
    t '<FormField',
    t { '', '  control={form.control}', '  name="' },
    i(1, 'fieldName'),
    t { '"', '  render={({ field }) => (', '    <FormItem>', '      <FormLabel>' },
    i(2, 'Label'),
    t { '</FormLabel>', '      <FormControl>', '        ' },
    i(3, '<input {...field} />'), -- placeholder: replace with <Select>, <Checkbox>, etc.
    t { '', '      </FormControl>', '      <FormMessage />', '    </FormItem>', '  )}', '/>' },
  }),
})
