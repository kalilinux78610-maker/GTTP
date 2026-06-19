import os

files_to_read = [
    ("1. THE DATA & DOMAIN LAYER (Models & Entities)", [
        "lib/features/courses/data/models/course_model.dart",
        "lib/features/courses/data/models/course_module_model.dart",
        "lib/features/courses/data/models/course_session_model.dart",
        "lib/features/courses/domain/entities/course.dart",
        "lib/features/courses/domain/entities/course_module.dart",
        "lib/features/courses/domain/entities/course_session.dart",
        "lib/features/reports/data/models/student_progress_model.dart",
    ]),
    ("2. THE DATA SOURCE & REPOSITORY LAYER (API & Caching)", [
        "lib/features/courses/data/repositories/courses_repository_impl.dart",
        "lib/features/courses/domain/repositories/courses_repository.dart",
        "lib/features/courses/data/datasources/courses_remote_datasource.dart",
        "lib/features/reports/domain/repositories/reports_repository.dart",
        "lib/features/reports/data/repositories/reports_repository_impl.dart",
        "lib/features/reports/data/datasources/reports_remote_datasource.dart",
    ]),
    ("3. THE STATE MANAGEMENT LAYER (Riverpod Providers)", [
        "lib/features/courses/presentation/providers/courses_provider.dart",
        "lib/features/courses/presentation/providers/course_details_provider.dart",
        "lib/features/courses/presentation/providers/course_module_provider.dart",
        "lib/features/reports/presentation/providers/reports_provider.dart",
    ]),
    ("4. THE PRESENTATION LAYER (UI Screens & Widgets)", [
        "lib/features/courses/presentation/screens/courses_screen.dart",
        "lib/features/courses/presentation/screens/course_details_screen.dart",
        "lib/features/courses/presentation/screens/course_module_detail_screen.dart",
        "lib/features/courses/presentation/screens/teacher_course_details_screen.dart",
        "lib/features/courses/presentation/screens/coordinator_course_details_screen.dart",
        "lib/features/courses/presentation/screens/pending_submissions_screen.dart",
        "lib/features/courses/presentation/screens/assignment_review_screen.dart",
    ]),
]

output_file = r"C:\Users\Nanu\.gemini\antigravity-ide\brain\f1a057d9-4503-41db-9b1b-d2a75e44651b\artifacts\course_source_code.md"
os.makedirs(os.path.dirname(output_file), exist_ok=True)
base_dir = r"s:\GTTP"

with open(output_file, 'w', encoding='utf-8') as outfile:
    outfile.write("# Course Module & Progress Tracking Source Code\n\n")
    
    for section_title, file_paths in files_to_read:
        outfile.write(f"=========================================\n")
        outfile.write(f"{section_title}\n")
        outfile.write(f"=========================================\n\n")
        
        for file_path in file_paths:
            full_path = os.path.join(base_dir, file_path)
            if os.path.exists(full_path):
                with open(full_path, 'r', encoding='utf-8') as infile:
                    content = infile.read()
                
                outfile.write(f"### {os.path.basename(file_path)}\n")
                outfile.write(f"Path: `{file_path}`\n\n")
                outfile.write(f"```dart\n{content}\n```\n\n")
            else:
                outfile.write(f"### {os.path.basename(file_path)}\n")
                outfile.write(f"Path: `{file_path}`\n\n")
                outfile.write(f"```dart\n// File not found\n```\n\n")

print("Artifact created successfully.")
