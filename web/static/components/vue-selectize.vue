<template>
  <select multiple placeholder="Tags" > </select>
</template>

<script>
  require('selectize')
  export default {
  props: ['selected'],
  methods: {
   update(){
      this.$emit('input', this.select.getValue()) 
   }
  },
  mounted: function(){
    var vm = this
    this.select = $(this.$el).selectize({
                plugins: ['remove_button'],
               maxItems: null,
					valueField: 'id',
          openOnFocus: false,
          hideSelected: true,
          closeAfterSelect: true,
					labelField: 'name',
					searchField: 'name',
                create: function(input) {
                        return {
                               id: input,
                               name: input
                               }
                }
   })[0].selectize

   this.select.on('change', vm.update)
  },

 watch: {
    selected: function (selected) {
        var vm = this
        this.select.off('change')
        this.select.addOption(selected);
        $.each(selected, function(i, item) {
                         vm.select.addItem(item.id)
        })
        this.select.on('change', vm.update)
    }
  },
  
}
</script>

<style lang="sass">
 
</style>


