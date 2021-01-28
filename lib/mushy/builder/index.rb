module Mushy
  module Builder
    module Index
      def self.file

<<-ENDEND
<html>
    <head>
        <link rel="stylesheet" href="/dark.css">
        <script src="/vue.js"></script>
        <script src="/axios.js"></script>
    </head>
    <body>
        <div id="app">
            <table>
                <tr v-for="flux in flow.fluxs">
                    <td>{{flux.name}}</td>
                    <td>{{flux.flux}}</td>
                    <td><a href="#" v-on:click.prevent.stop="edit({ flux: flux, setup: setup, configs: configs })">[Edit]</a></td>
                </tr>
            </table>
            <mip-heavy :data="setup"></mip-heavy>
            <mip-heavy v-for="(data, id) in configs" v-show="setup.flux.value === id" :data="data"></mip-heavy>
            <div v-if="results.loading">Loading...</div>
            <div v-else>{{results.length}} result{{results.length == 1 ? "" : "s"}}</div>
            <mip-heavy v-for="data in results" :data="data"></mip-heavy>
        </div>
    </body>
</html>

<script type="text/javascript">

   var fancyName = function(id) { return '(' + id + '.split(/[ _]/).map(function(x){return x[0].toUpperCase() + x.substring(1)}).join(\\' \\'))' };
   var thingToData = function(thing) {
                         var record = {};
                         for (var key in thing)
                             if (thing[key].value)
                                 if (thing[key].type == 'json')
                                     record[key] = JSON.parse(thing[key].value);
                                 else
                                     record[key] = thing[key].value;
                         return record;
                     };

   var components = {
       label: {
           props: ['label', 'description'],
           template: '<label :for="id" v-if="label != \\'\\'">{{label || ' + fancyName('id') + '}} <i v-show="description">({{description}})</i></label>'
       },
       text:  {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><input type="text" :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value);" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></div>'
       },
       integer:  {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><input type="text" :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value);" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></div>'
       },
       email: {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><input type="email" :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value)" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></div>'
       },
       textarea: {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><textarea :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value)" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></textarea></div>'
       },
       json: {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><pre><code>{{value}}</code></pre><textarea :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value)" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></textarea></div>'
       },
       jsonview: {
           data: function() {
               return {
                   toggle: function(view) { return view == 'beautiful' ? 'thin' : 'beautiful'; },
                   copy: function(view, json) { console.log(view); return navigator.clipboard.writeText((view == 'beautiful' ? JSON.stringify(json, null, "  ") : JSON.stringify(json))); },
                   show: function(view, json) { return view == 'beautiful' ? JSON.stringify(json, null, "  ") : JSON.stringify(json); },
               };
           },
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description', 'view'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label> <a href="#" v-on:click.prevent.stop="view=toggle(view)">{{(view == \\'beautiful\\' ? \\'>\\' : \\'^\\')}}</a><a href="#" v-on:click.prevent.stop="copy(view, value)">copy</a><pre><code>{{show(view, value)}}</code></pre></div>'
       },
       radio: {
           props: ['label', 'value', 'options', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><div v-for="option in options"><input type="radio" :name="id" v-bind:value="option" v-on:input="$emit(\\'update:value\\', $event.target.value)" :checked="value == option"> <label for="option">{{option}}</label></div></div>'
       },
       select: {
           props: ['label', 'value', 'options', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><select :name="id" v-on:input="$emit(\\'update:value\\', $event.target.value)"><option v-for="option in options" v-bind:value="option" :selected="value == option">{{option}}</option></select></div>'
       },
       boolean: {
           props: ['label', 'value', 'options', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><select :name="id" v-on:input="$emit(\\'update:value\\', $event.target.value)"><option v-for="option in [true, false]" v-bind:value="option" :selected="value == option">{{option}}</option></select></div>'
       },
       table: {
           props: ['value', 'description'],
           template: '<table><tr><th v-for="(d, i) in value[0]">{{' + fancyName('i') + '}}</th></tr><tr v-for="v in value"><td v-for="(d, i) in v">{{d}}</td></tr></table>'
       },
       editgrid: {
           data: function() {
               return {
                   removeRecord: function(record, records, index) { records.splice(index, 1); },
                   addRecord: function(editors, records) {
                                                    var record = {};
                                                    for (var i = 0; i < editors.length; i++)
                                                    {
                                                        record[editors[i].target] = editors[i].field.value;
                                                        editors[i].field.value = editors[i].field.default ? editors[i].field.default : '';
                                                    }
                                                    records.push(record);
                                                }
               };
           },
           props: ['value', 'editors', 'label', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><table><tr><th v-for="(d, i) in value[0]">{{' + fancyName('i') + '}}</th></tr><tr v-for="(v, z) in value"><td v-for="(d, i) in v">{{d}}</td><td><a href="#" v-on:click.prevent.stop="removeRecord(v, value, z)">[x]</a></td></tr><tr><td v-for="editor in editors"><mip-thing :data="editor.field" :id="editor.id"></mip-thing></td><td><a href="#" v-on:click.prevent.stop="addRecord(editors, value)">[Add]</a></td></tr></table></div>'
       },
       keyvalue: {
           data: function() {
               return {
                   removeRecord: function(data, key) { Vue.delete(data, key) },
                   addRecord: function(editors, data) {
                                                   Vue.set(data, editors[0].field.value, editors[1].field.value)
                                                   editors[0].field.value = editors[0].field.default;
                                                   editors[1].field.value = editors[1].field.default;
                                                }
               };
           },
           props: ['value', 'label', 'editors', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><table><tr v-for="(v, k) in value"><td>{{k}}</td><td>{{v}}</td><td><a href="#" v-on:click.prevent.stop="removeRecord(value, k)">[x]</a></td></tr><tr><td v-for="editor in editors"><mip-thing :data="editor.field" :id="editor.id"></mip-thing></td><td><a href="#" v-on:click.prevent.stop="addRecord(editors, value)" v-show="editors[0].field.value">[Add]</a></td></tr></table></div>'
       },
       button: {
           props: ['click', 'description'],
           template: '<button v-on:click.prevent.stop="click(pull(this))">{{id}}</button>'
       }
   };

   for(var property in components)
   {
       var props = JSON.parse(JSON.stringify(components[property].props));
       props.push('id');
       Vue.component('mip-' + property, {
            data: components[property].data ?? function () {
                      var foundIt = this.$parent;
                      var counter = 0;
                      while (foundIt.$parent.constructor.name == "VueComponent" && counter < 10)
                      {
                        foundIt = foundIt.$parent;
                        counter += 1;
                      }
                      return {
                          console: console,
                          pull: function(x) { return thingToData(foundIt.data); },
                      }
                  },
            props: props,
            template: components[property].template
       });
   }

   var thingTemplate = '<div>';
   for (var property in components)
       thingTemplate = thingTemplate + '<mip-' + property + ' v-if="data.type == \\'' + property + '\\'" :id="id" ' + components[property].props.map(function(x){ return ':' + x + '.sync="data.' + x + '"';}).join(' ') + '></mip-' + property + '>'
   thingTemplate = thingTemplate + '</div>';

   Vue.component('mip-thing', {
        data: function () {
                  return {
                      console: console,
                  }
        },
        props: ['data', 'value', 'id', 'model'],
        template: thingTemplate
    });

   Vue.component('mip-heavy', {
        data: function () {
                  return {
                      console: console,
                  }
        },
        props: ['data'],
        template: '<div><mip-thing v-for="(d, id) in data" :data="d" :id="id"></mip-thing></div>',
    });

    var sample = {
                     email: { type: 'email', value: 'darren@cauthon.com' },
                     first_name: { type: 'text', value: 'Darren' },
                     description: { type: 'textarea', value: 'more data' },
                     size: { type: 'select', value: 'medium', options: ['small', 'medium', 'large']},
                     heynow: { type: 'keyvalue',
                             value: {
                                 first_name: 'John',
                                 last_name: 'Doe',
                             },
                             editors: [
                                         { id: 'new_key', target: 'key', field: { type: 'text', value: '', default: '' } },
                                         { id: 'new_value', target: 'value', field: { type: 'text', value: '', default: '' } }
                                      ] },
                     past: { type: 'editgrid',
                             value: [
                                 { name: 'Godzilla', quantity: 1 },
                                 { name: 'Mothra', quantity: 2 },
                             ],
                             editors: [
                                         { id: 'new_name', target: 'name', field: { type: 'text', value: '', default: '' } },
                                         { id: 'new_quantity', target: 'quantity', field: { type: 'select', value: '1', options: [1, 2, 3], default: 1 } }
                                      ] },
                     super_action: { type: 'button', click: function(x) { console.log(x) } },
                 };

    var app = null;

    axios.get('/fluxs')
         .then(function(data){

             var configs = {};
             data.data.fluxs.map(function(x){
                 configs[x.name] = x.config;
             });

             var setup = {
                   event: { type: 'json', value: '{}' },
                   id: { type: 'text', value: '' },
                   name: { type: 'text', value: '' },
                   flux: { type: 'select', value: data.data.fluxs[0].name, options: data.data.fluxs.map(function(x){ return x.name })},
             };

             for (var key in configs)
             {
                 configs[key].go = { type: 'button', click: function(c) {
                                      app.results = [];
                                      Vue.set(app.results, 'loading', true);
                                      axios.post('/run', { config: c, setup: thingToData(app.setup) })
                                       .then(function(r){
                                           Vue.set(app.results, 'loading', false);
                                           for (var key in r.data.result)
                                               app.results.push({darren: { type:'jsonview', value: r.data.result[key], view: 'thin' }});
                                        });
                                     } };

                 configs[key].save = { type: 'button', click: function(config) {
                     var setup = thingToData(app.setup);
                                       var flux = {
                                           id: setup.id,
                                           name: setup.name,
                                           flux: setup.flux,
                                           config: config,
                                       };
                     app.flow.fluxs.push(flux);
                     console.log(flux);
                                     }
                 };
             }

             app = new Vue({
                 el: '#app',
                 data: {
                     flow: {
                         fluxs: [],
                     },
                     edit: function(x, y, z, abc) {
                         var flux = x.flux;
                         var applicable_config = x.configs[x.flux.flux];
                         console.log(x);
                         console.log(flux);
                         console.log(applicable_config);
                         for(var key in applicable_config)
                             if (flux.config[key])
                                Vue.set(applicable_config[key], 'value', flux.config[key]);
                     },
                     configs: configs,
                     setup: setup,
                     results: [],
                 }
            });
    });
</script>
ENDEND

      end
    end
  end
end