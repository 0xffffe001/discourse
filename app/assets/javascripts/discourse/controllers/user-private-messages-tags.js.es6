export default Ember.Controller.extend({
  sortProperties: ['count:desc', 'id'],
  tagsForUser: null,

  actions: {
    sortByCount() {
      this.set('sortProperties', ['count:desc', 'id']);
    },

    sortById() {
      this.set('sortProperties', ['id']);
    }
  }
});
