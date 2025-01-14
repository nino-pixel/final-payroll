    <template>
    <!-- ... existing template code ... -->
    <div class="modal fade" id="employeeModal" tabindex="-1">
        <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
            <h5 class="modal-title">{{ isEditing ? 'Edit Employee' : 'Add Employee' }}</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
            <form @submit.prevent="handleSubmit">
                <!-- ... existing form fields ... -->

                <!-- Add Shift Schedule Section -->
                <div class="mb-3">
                <label class="form-label">Shift Schedule</label>
                <select v-model="formData.shift_schedule_id" class="form-select">
                    <option value="">Select Shift</option>
                    <option v-for="schedule in shiftSchedules" 
                            :key="schedule.id" 
                            :value="schedule.id">
                    {{ schedule.name }} ({{ formatTime(schedule.start_time) }} - {{ formatTime(schedule.end_time) }})
                    </option>
                </select>
                </div>

                <!-- Custom Schedule Times -->
                <div class="mb-3" v-if="formData.shift_schedule_id">
                <label class="form-label">Customize Schedule Times</label>
                <div class="row g-2">
                    <div class="col">
                    <input type="time" 
                            v-model="formData.custom_start_time" 
                            class="form-control" 
                            placeholder="Start Time">
                    </div>
                    <div class="col">
                    <input type="time" 
                            v-model="formData.custom_end_time" 
                            class="form-control" 
                            placeholder="End Time">
                    </div>
                </div>
                <small class="text-muted">Leave blank to use default shift times</small>
                </div>

                <!-- ... rest of the form ... -->
            </form>
            </div>
        </div>
        </div>
    </div>
    </template>

    <script>
    export default {
    data() {
        return {
        // ... existing data ...
        shiftSchedules: [],
        formData: {
            // ... existing form fields ...
            shift_schedule_id: '',
            custom_start_time: '',
            custom_end_time: ''
        }
        }
    },
    methods: {
        async loadShiftSchedules() {
        try {
            const response = await axios.get('/api/shift-schedules');
            this.shiftSchedules = response.data;
        } catch (error) {
            console.error('Error loading shift schedules:', error);
        }
        },
        formatTime(time) {
        return new Date('2000-01-01 ' + time).toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        });
        },
        resetForm() {
        this.formData = {
            // ... existing reset fields ...
            shift_schedule_id: '',
            custom_start_time: '',
            custom_end_time: ''
        };
        },
        async editEmployee(employee) {
        this.isEditing = true;
        this.formData = {
            ...employee,
            shift_schedule_id: employee.shift_schedule_id || '',
            custom_start_time: employee.custom_start_time || '',
            custom_end_time: employee.custom_end_time || ''
        };
        },
        async handleSubmit() {
        try {
            const payload = {
            ...this.formData,
            custom_schedule: this.formData.shift_schedule_id ? {
                start_time: this.formData.custom_start_time || null,
                end_time: this.formData.custom_end_time || null
            } : null
            };

            if (this.isEditing) {
            await axios.put(`/api/employees/${this.formData.id}`, payload);
            } else {
            await axios.post('/api/employees', payload);
            }

            this.loadEmployees();
            $('#employeeModal').modal('hide');
            this.resetForm();
        } catch (error) {
            console.error('Error submitting form:', error);
        }
        }
    },
    mounted() {
        this.loadShiftSchedules();
        // ... existing mounted code ...
    }
    }
    </script> 