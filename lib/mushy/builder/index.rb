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
            <table v-if="setup.showFlux == false">
                <tr>
                    <th>Name</th>
                    <th>Parent</th>
                    <th>Actions</th>
                </tr>
                <tr v-for="flux in flow.fluxs">
                    <td>{{flux.name}}</td>
                    <td>{{flux_name_for(flux.parent, flow.fluxs)}}</td>
                    <td><button v-on:click.prevent.stop="edit({ flux: flux, setup: setup, configs: configs })">Edit</button></td>
                </tr>
            </table>
            <button v-if="setup.showFlux == false" v-on:click.prevent.stop="startNew({ setup: setup, configs: configs })">Start a New Flux</button>
            <button v-if="setup.showFlux == false" v-on:click.prevent.stop="saveFlow({ setup: setup, flow: flow })">Save This Flow</button>
            <button v-if="setup.showFlux" v-on:click.prevent.stop="setup.showFlux = false">&lt; Go Back To List</button>
            <div v-if="setup.showFlux">
                <mip-heavy :data="setup"></mip-heavy>
                <mip-heavy v-for="(data, id) in configs" v-show="setup.flux.value === id" :data="data"></mip-heavy>
                <div v-if="results.loading">Loading...</div>
                <div v-else>{{results.length}} result{{results.length == 1 ? "" : "s"}}</div>
                <mip-heavy v-for="data in results" :data="data"></mip-heavy>
            </div>
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
           props: ['label', 'description', 'hide_description'],
           template: '<label :for="id" v-if="label != \\'\\'">{{label || ' + fancyName('id') + '}} <i v-show="description && !hide_description">({{description}})</i></label>'
       },
       text:  {
           props: ['label', 'placeholder', 'disabled', 'readonly', 'value', 'description', 'shrink'],
           template: '<div><mip-label :id="id" :label="label" :description="description" :hide_description="shrink"></mip-label> <a href="#" v-on:click.prevent.stop="shrink=false" v-show="shrink && !value">[^]</a><input type="text" :name="id" v-if="value || !shrink" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value);" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></div>'
       },
       hide:  {
           props: ['label', 'description'],
           template: '<mip-label :id="id" :label="label" :description="description" v-if="false"></mip-label>'
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
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><textarea :name="id" :placeholder="placeholder" v-bind:value="value" v-on:input="$emit(\\'update:value\\', $event.target.value)" :disabled="disabled == \\'true\\'" :readonly="readonly == \\'true\\'"></textarea></div>'
       },
       jsonview: {
           data: function() {
               return {
                   toggle: function(view) { return view == 'beautiful' ? 'thin' : 'beautiful'; },
                   copy: function(view, json) { return navigator.clipboard.writeText((view == 'beautiful' ? JSON.stringify(json, null, "  ") : JSON.stringify(json))); },
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
       selectrecord: {
           props: ['label', 'value', 'options', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><select :name="id" v-on:input="$emit(\\'update:value\\', $event.target.value)"><option v-for="option in options" v-bind:value="option.id" :selected="value == option.id">{{option.name}}</option></select></div>'
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
                   actionText: function(value, others) { found = false; for(var i in others){ if (i == value) found = true; } return found ? 'Replace' : 'Add'; },
                   removeRecord: function(data, key) { Vue.delete(data, key) },
                   addRecord: function(editors, data) {
                                                   Vue.set(data, editors[0].field.value, editors[1].field.value)
                                                   editors[0].field.value = editors[0].field.default;
                                                   editors[1].field.value = editors[1].field.default;
                                                }
               };
           },
           props: ['value', 'label', 'editors', 'description'],
           template: '<div><mip-label :id="id" :label="label" :description="description"></mip-label><table><tr v-for="(v, k) in value"><td>{{k}}</td><td>{{v}}</td><td><button v-on:click.prevent.stop="removeRecord(value, k)">Remove {{k}}</button></td></tr><tr><td v-for="editor in editors"><mip-thing :data="editor.field" :id="editor.id"></mip-thing></td><td><button v-on:click.prevent.stop="addRecord(editors, value)" v-show="editors[0].field.value">{{actionText(editors[0].field.value, value)}} {{editors[0].field.value}}</button></td></tr></table></div>'
       },
       button: {
           props: ['click', 'description', 'name'],
           template: '<button v-on:click.prevent.stop="click(pull(this))">{{name || id}}</button>'
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

    var app = null;

    axios.get('/fluxs')
         .then(function(fluxdata){

    axios.get('/flow')
         .then(function(flowdata){

             fluxdata = fluxdata.data;
             flowdata = flowdata.data;

             var configs = {};
             fluxdata.fluxs.map(function(x){
                 configs[x.name] = x.config;
             });

             var options = [''];
             fluxTypes = fluxdata.fluxs.map(function(x){ return x.name });
             for(var type in fluxTypes)
                options.push(fluxTypes[type]);

             var setup = {
                   showFlux: false,
                   id: { type: 'hide', value: '' },
                   name: { type: 'text', value: '' },
                   flux: { type: 'select', value: fluxdata.fluxs[0].name, options: options},
                   parent: { type: 'selectrecord', value: '', options: flowdata.fluxs },
             };

             for (var key in configs)
             {
                 configs[key].save = { type: 'button', name: 'Save This Flux', click: function(config) {
                     var setup = thingToData(app.setup);
                                       var flux = {
                                           id: setup.id,
                                           name: setup.name,
                                           flux: setup.flux,
                                           parent: setup.parent,
                                           config: config,
                                       };
                     var index = -1;
                     for(var i = 0; i < app.flow.fluxs.length; i++)
                        if (app.flow.fluxs[i].id == flux.id)
                            index = i;
                     if (index < 0)
                         app.flow.fluxs.push(flux);
                     else
                         app.flow.fluxs[index] = flux;

                     app.setup.id.value = '';

                     Vue.set(app.setup, 'showFlux', false);
                                     }
                 };

                 configs[key].test_event = { type: 'json', value: '{}', default: '{}' };

                 configs[key].run_test = { type: 'button', name: 'Test Run This Flux', click: function(c) {
                                      app.results = [];
                                      Vue.set(app.results, 'loading', true);
                                      var the_setup = thingToData(app.setup);
                                      the_setup.event = c.test_event;
                                      axios.post('/run', { config: c, setup: the_setup })
                                       .then(function(r){
                                           Vue.set(app.results, 'loading', false);
                                           var index = 1;
                                           for (var key in r.data.result)
                                           {
                                              var result = {};
                                              result['event_' + index] = { type: 'jsonview', value: r.data.result[key], view: 'thin' };
                                              app.results.push(result);
                                              index += 1;
                                           }
                                        });
                                     } };
             }

             var loadThisFlux = function(args)
             {
                 var flux = args.flux;
                 var setup = args.setup;
                 var config = args.config;

                 Vue.set(setup.id, 'value', flux.id);
                 Vue.set(setup.name, 'value', flux.name);
                 Vue.set(setup.flux, 'value', flux.flux);
                 Vue.set(setup.parent, 'value', flux.parent);

                 var applicable_config = configs[flux.flux];
                 for(var key in applicable_config)
                     if (flux.config[key])
                         Vue.set(applicable_config[key], 'value', flux.config[key]);
                     else
                         Vue.set(applicable_config[key], 'value', applicable_config[key].default);


                 options = flowdata.fluxs.filter(function(x){ return x.id != flux.id });
                 options.unshift( { id: '', name: '' } );
                 setup.parent.options = options;

                 Vue.set(setup, 'showFlux', true);
                 app.results = [];
             };

             function uuidv4() {
                 return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
                     (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
                 );
             }

             app = new Vue({
                 el: '#app',
                 data: {
                     flow: flowdata,
                     startNew: function(x) {
                         flux = {
                             id: uuidv4(),
                             name: '',
                             config: {}
                         };
                         loadThisFlux({ flux: flux, setup: x.setup, configs: x.configs });
                     },
                     edit: function(x) {
                         var flux = x.flux;

                         loadThisFlux({ flux: x.flux, setup: x.setup, configs: x.configs });
                     },
                     saveFlow: function(input)
                     {
                         var setup = input.setup;
                         var flow = input.flow;
                         axios.post('/save', flow)
                            .then(function(result){
                                Vue.set(setup, 'showFlux', false);
                            });
                     },
                     configs: configs,
                     setup: setup,
                     flux_name_for: function(id, fluxes) {
                         var flux = fluxes.filter(function(x){ return x.id == id })[0];
                         return flux != undefined ? flux.name : '';
                     },
                     results: [],
                 }
            });
    });
    });
</script>
ENDEND

      end
    end
  end
end