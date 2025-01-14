<!-- filepath: /e:/backup/LOGIN DESIGN/web_vue/src/components/DepartmentForm.vue -->
<template>
    <div>
      <h1>{{ isEdit ? 'Edit' : 'Create' }} Department</h1>
      <form @submit.prevent="submitForm">
        <div>
          <label for="name">Name:</label>
          <input type="text" v-model="form.name" required>
        </div>
        <div>
          <label for="code">Code:</label>
          <input type="text" v-model="form.code" required>
        </div>
        <div>
          <label for="description">Description:</label>
          <textarea v-model="form.description"></textarea>
        </div>
        <button type="submit">{{ isEdit ? 'Update' : 'Create' }}</button>
      </form>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    data() {
      return {
        form: {
          name: '',
          code: '',
          description: ''
        },
        isEdit: false
      };
    },
    methods: {
      async fetchDepartment() {
        if (this.isEdit) {
          const response = await axios.get(`/api/departments/${this.$route.params.id}`);
          this.form = response.data;
        }
      },
      async submitForm() {
        if (this.isEdit) {
          await axios.put(`/api/departments/${this.$route.params.id}`, this.form);
        } else {
          await axios.post('/api/departments', this.form);
        }
        this.$router.push('/departments');
      }
    },
    mounted() {
      this.isEdit = !!this.$route.params.id;
      this.fetchDepartment();
    }
  };
  </script>
  <style>

  label, input{
    color:black;
  }



</style>